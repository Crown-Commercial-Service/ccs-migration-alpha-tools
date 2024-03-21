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
