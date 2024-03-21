resource "aws_iam_role_policy" "create_rds_postgres_tester_lambda__get_postgres_password" {
  name   = "get-postgres-password"
  role   = module.create_rds_postgres_tester_lambda.service_role_name
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

module "create_rds_postgres_tester_lambda" {
  source = "../../resource-groups/deployed-lambda"

  dist_folder_path      = "${path.module}/lambdas/dist"
  dist_package_filename = "create_rds_postgres_tester.zip"

  dist_package_hash = {
    base64sha256 = data.archive_file.create_rds_postgres_tester_lambda_zip.output_base64sha256
    md5          = data.archive_file.create_rds_postgres_tester_lambda_zip.output_md5
  }

  environment_variables = {
    DBNAME  = var.db_name
    RDSHOST = var.rds_host
  }

  function_name         = "create-rds-postgres-tester"
  handler               = "create_rds_postgres_tester.lambda_handler"
  lambda_dist_bucket_id = var.lambda_dist_bucket_id
  timeout_seconds       = 60
}

data "archive_file" "create_rds_postgres_tester_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/create_rds_postgres_tester"
  output_path = "${path.module}/lambdas/dist/create_rds_postgres_tester.zip"
}

# Lambda Layer with requirements.txt
resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1("${path.module}/lambdas/create_rds_postgres_tester/requirements.txt")
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
      mkdir /tmp/lambda-layer
      cd /tmp/lambda-layer
      curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
      python3 get-pip.py
      pip3 install -r ${path.module}/lambdas/create_rds_postgres_tester/requirements.txt -t .
    EOT
  }
}

data "archive_file" "lambda_layer_zip" {
  depends_on = [ null_resource.lambda_layer ]
  output_path = "${path.module}/lambdas/dist/layer.zip"
  source_dir  = "/tmp/lambda-layer"
  type        = "zip"
}

resource "aws_s3_object" "lambda_layer" {
  bucket = var.lambda_dist_bucket_id
  key    = "layer.zip"
  source = data.archive_file.lambda_layer_zip.output_path
}

resource "aws_lambda_layer_version" "this" {
  s3_bucket           = var.lambda_dist_bucket_id
  s3_key              = aws_s3_object.lambda_layer.key
  layer_name          = "layer"
  compatible_runtimes = ["python3.9"]
  skip_destroy        = true
  depends_on          = [aws_s3_object.lambda_layer]
}
