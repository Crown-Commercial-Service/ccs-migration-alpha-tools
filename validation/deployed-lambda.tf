resource "aws_s3_bucket" "lambda_deploy" {}

module "deployed_lambda" {
  source = "../resource-groups/deployed-lambda"

  dist_folder_path      = "${path.module}/deployed-lambda/dist"
  dist_package_filename = "dummy.zip"
  dist_package_hash = {
    base64sha256 = "12345=="
    md5          = "abcd"
  }
  function_name         = "dummy-function"
  lambda_dist_bucket_id = aws_s3_bucket.lambda_deploy.id
}

data "archive_file" "dummy_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/deployed-lambda"
  output_path = "${path.module}/deployed-lambda/dist/dummy.zip"
}
