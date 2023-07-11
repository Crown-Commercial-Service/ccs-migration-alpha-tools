resource "aws_sfn_state_machine" "compile_transfer_list" {
  name     = "${var.migrator_name}-compile-transfer-list"
  role_arn = aws_iam_role.compile_transfer_list_sfn.arn

  definition = <<EOF
{
  "Comment": "Compile the list of S3 objects to transfer from the GPaaS bucket into the native bucket",
  "StartAt": "Compile source object list",
  "States": {
    "Compile source object list": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${module.compile_transfer_list_lambda.function_arn}",
        "Payload": {
          "gpaas_service_key_ssm_param_name": "${aws_ssm_parameter.gpaas_service_key.name}",
          "transfer_list_table_name": "${aws_dynamodb_table.transfer_list.name}"
        }
      },
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role" "compile_transfer_list_sfn" {
  name = "${var.migrator_name}-compile-transfer-list-sfn"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Sid = "AllowStatesAssumeRole"

        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "compile_transfer_list_sfn__invoke_compile_transfer_list_lambda" {
  name   = "invoke-compile-transfer-list-lambda"
  role   = aws_iam_role.compile_transfer_list_sfn.id
  policy = module.compile_transfer_list_lambda.invoke_lambda_iam_policy_json
}

module "compile_transfer_list_lambda" {
  source = "../../resource-groups/deployed-lambda"

  dist_folder_path      = "${path.module}/lambdas/dist"
  dist_package_filename = "compile_transfer_list.zip"
  dist_package_hash = {
    base64sha256 = data.archive_file.compile_transfer_list_lambda_zip.output_base64sha256
    md5          = data.archive_file.compile_transfer_list_lambda_zip.output_md5
  }
  function_name         = "${var.migrator_name}-compile-transfer-list"
  lambda_dist_bucket_id = var.lambda_dist_bucket_id
}

data "archive_file" "compile_transfer_list_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/compile_transfer_list"
  output_path = "${path.module}/lambdas/dist/compile_transfer_list.zip"
}

resource "aws_iam_role_policy" "compile_transfer_list_lambda__put_transfer_list_item" {
  name   = "put-transfer-list-item"
  role   = module.compile_transfer_list_lambda.service_role_name
  policy = data.aws_iam_policy_document.put_transfer_list_item.json
}

resource "aws_iam_role_policy" "compile_transfer_list_lambda__read_gpaas_service_key_ssm" {
  name   = "read-gpaas-service-key-ssm"
  role   = module.compile_transfer_list_lambda.service_role_name
  policy = data.aws_iam_policy_document.read_gpaas_service_key_ssm.json
}
