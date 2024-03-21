resource "aws_iam_role_policy" "create_rds_postgres_tester_lambda__get_postgres_password" {
  name   = "get-postgres-password"
  role   = module.this.service_role_name
  policy = data.aws_iam_policy_document.get_postgres_password.json
}

data "aws_iam_policy_document" "get_postgres_password" {
  version = "2012-10-17"

  statement {
    sid = "AllowSSMGetParameter"

    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.db_name}-postgres-connection-password"
    ]
  }
}

module "this" {
  source = "../../resource-groups/deployed-lambda"

  dist_folder_path      = "${path.module}/lambdas/dist"
  dist_package_filename = "create_rds_postgres_tester.zip"

  dist_package_hash = {
    base64sha256 = data.archive_file.function.output_base64sha256
    md5          = data.archive_file.function.output_md5
  }

  environment_variables = {
    DBNAME  = var.db_name
    RDSHOST = var.rds_host
  }

  function_name         = "create-rds-postgres-tester"
  handler               = "create_rds_postgres_tester.lambda_handler"
  lambda_dist_bucket_id = var.lambda_dist_bucket_id
  layer_arns            = [aws_lambda_layer_version.dependencies.arn]
  timeout_seconds       = 60
}

data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/create_rds_postgres_tester"
  output_path = "${path.module}/lambdas/dist/create_rds_postgres_tester.zip"
}

# Lambda Layer with requirements.txt
resource "null_resource" "dependencies" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
      cd "${path.module}/dependencies/python"
      pyenv global 3.11.3
      pip install --upgrade pip
      pip install -r requirements.txt --target .
    EOT
  }
}

data "archive_file" "dependencies" {
  depends_on  = [null_resource.dependencies]
  output_path = "${path.module}/lambdas/dist/dependencies.zip"
  source_dir  = "${path.module}/dependencies"
  type        = "zip"
}

resource "aws_s3_object" "dependencies" {
  bucket = var.lambda_dist_bucket_id
  key    = "create_rds_postgres_tester.zip_dependencies.zip"
  source = data.archive_file.dependencies.output_path

  etag = data.archive_file.dependencies.output_md5
}

resource "aws_lambda_layer_version" "dependencies" {
  s3_bucket           = var.lambda_dist_bucket_id
  s3_key              = aws_s3_object.dependencies.key
  source_code_hash    = filebase64sha256("${path.module}/lambdas/dist/dependencies.zip")
  layer_name          = "create-rds-postgres-tester-dependencies"
  compatible_runtimes = ["python3.9"]
  skip_destroy        = true
}
