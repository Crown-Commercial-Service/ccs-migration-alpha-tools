locals {
  dist_package_full_path = "${var.dist_folder_path}/${var.dist_package_filename}"
}

resource "aws_s3_object" "deploy_object" {
  bucket        = var.lambda_dist_bucket_id
  force_destroy = var.is_ephemeral
  key           = var.dist_package_filename
  source        = local.dist_package_full_path

  etag = var.dist_package_hash.md5
}

resource "aws_lambda_function" "function" {
  function_name = var.function_name

  s3_bucket = aws_s3_object.deploy_object.bucket
  s3_key    = aws_s3_object.deploy_object.key

  runtime     = var.runtime
  handler     = var.handler
  timeout     = var.timeout_seconds
  memory_size = var.runtime_memory_size

  layers = var.layer_arns

  ephemeral_storage {
    size = var.ephemeral_storage_size_mb
  }

  source_code_hash = var.dist_package_hash.base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = var.environment_variables
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Sid = ""

        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_exec__write_logs" {
  name   = "write-logs"
  role   = aws_iam_role.lambda_exec.name
  policy = module.lambda_log_group.write_log_group_policy_document_json
}

data "aws_iam_policy_document" "invoke_lambda" {
  version = "2012-10-17"

  statement {
    sid = "Invoke${replace(var.function_name, "-", "")}Lambda"

    actions = [
      "lambda:InvokeFunction"
    ]

    effect = "Allow"

    resources = [
      aws_lambda_function.function.arn
    ]
  }
}
