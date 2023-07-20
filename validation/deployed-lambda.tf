resource "aws_s3_bucket" "lambda_deploy" {}

module "deployed_lambda" {
  source = "../resource-groups/deployed-lambda"

  dist_folder_path      = "${path.module}/deployed-lambda/dist"
  dist_package_filename = "dummy.zip"
  dist_package_hash = {
    base64sha256 = "12345=="
    md5          = "abcd"
  }
  environment_variables = {
    APP_NAME : "App001"
  }
  ephemeral_storage_size_mb = 1024
  function_name             = "dummy-function"
  handler                   = "index.handler"
  is_ephemeral              = true
  lambda_dist_bucket_id     = aws_s3_bucket.lambda_deploy.id
  log_retention_days        = 14
  runtime                   = "python3.11"
  runtime_memory_size       = 1024
  timeout_seconds           = 60
}

data "archive_file" "dummy_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/deployed-lambda"
  output_path = "${path.module}/deployed-lambda/dist/dummy.zip"
}
