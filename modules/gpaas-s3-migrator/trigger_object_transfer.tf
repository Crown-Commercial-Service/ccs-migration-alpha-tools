resource "aws_lambda_event_source_mapping" "handle_new_transfer_items" {
  batch_size             = 40 # Maximum number of concurrent iterations in an SFN Map
  event_source_arn       = aws_dynamodb_table.transfer_list.stream_arn
  function_name          = module.handle_new_transfer_items_lambda.function_arn
  parallelization_factor = 10
  starting_position      = "LATEST"

  filter_criteria {
    filter {
      pattern = jsonencode({
        eventName = ["INSERT"]
      })
    }
  }
}

module "handle_new_transfer_items_lambda" {
  source = "../../resource-groups/deployed-lambda"

  dist_folder_path      = "${path.module}/lambdas/dist"
  dist_package_filename = "handle_new_transfer_items.zip"
  dist_package_hash = {
    base64sha256 = data.archive_file.handle_new_transfer_items_lambda_zip.output_base64sha256
    md5          = data.archive_file.handle_new_transfer_items_lambda_zip.output_md5
  }
  environment_variables = {
    TRANSFER_OBJECTS_STATE_MACHINE_ARN = aws_sfn_state_machine.transfer_objects.arn
  }
  function_name         = "${var.migrator_name}-handle-new-transfer-items"
  lambda_dist_bucket_id = var.lambda_dist_bucket_id
}

data "archive_file" "handle_new_transfer_items_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/handle_new_transfer_items"
  output_path = "${path.module}/lambdas/dist/handle_new_transfer_items.zip"
}

resource "aws_iam_role_policy" "handle_new_transfer_items_lambda__consume_transfer_stream" {
  name = "consume-transfer-stream"
  role = module.handle_new_transfer_items_lambda.service_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.transfer_list.stream_arn
        ]
      },
      {
        Action = [
          "dynamodb:ListStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "handle_new_transfer_items_lambda__start_transfer_objects_sfn" {
  name   = "start-transfer-objects-sfn"
  role   = module.handle_new_transfer_items_lambda.service_role_name
  policy = data.aws_iam_policy_document.start_transfer_objects_sfn.json
}
