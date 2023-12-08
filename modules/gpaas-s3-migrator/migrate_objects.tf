resource "aws_sqs_queue" "objects_to_migrate" {
  name                       = "${var.migrator_name}-objects-to-migrate"
  visibility_timeout_seconds = 120
}

data "aws_iam_policy_document" "send_new_objects_to_migrate_message" {
  version = "2012-10-17"

  statement {
    sid = "AllowSendObjectsToMigrateMessage"

    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.objects_to_migrate.arn
    ]
  }
}

data "aws_iam_policy_document" "process_objects_to_migrate_queue" {
  version = "2012-10-17"

  statement {
    sid = "AllowProcessObjectsToMigrateQueue"

    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]

    resources = [
      aws_sqs_queue.objects_to_migrate.arn
    ]
  }
}

resource "aws_lambda_event_source_mapping" "objects_to_migrate" {
  event_source_arn                   = aws_sqs_queue.objects_to_migrate.arn
  function_name                      = module.migrate_batch_of_objects_lambda.function_arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 5

  scaling_config {
    maximum_concurrency = var.migration_workers_maximum_concurrency
  }
}

module "migrate_batch_of_objects_lambda" {
  source = "../../resource-groups/deployed-lambda"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region

  dist_folder_path      = "${path.module}/lambdas/dist"
  dist_package_filename = "migrate_batch_of_objects.zip"
  dist_package_hash = {
    base64sha256 = data.archive_file.migrate_batch_of_objects_lambda_zip.output_base64sha256
    md5          = data.archive_file.migrate_batch_of_objects_lambda_zip.output_md5
  }
  environment_variables = {
    GPAAS_SERVICE_KEY_SSM_PARAM_NAME = aws_ssm_parameter.gpaas_service_key.name
    TARGET_BUCKET_ID                 = var.target_bucket_id
    TRANSFER_LIST_TABLE_NAME         = aws_dynamodb_table.objects_to_migrate.name
  }
  ephemeral_storage_size_mb = 5 * 1024 + 128 # 5GB object limit plus 128MB operational spare
  function_name             = "${var.migrator_name}-migrate-batch-of-objects"
  lambda_dist_bucket_id     = var.lambda_dist_bucket_id
  runtime_memory_size       = 2048
  timeout_seconds           = 120
}

data "archive_file" "migrate_batch_of_objects_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/migrate_batch_of_objects"
  output_path = "${path.module}/lambdas/dist/migrate_batch_of_objects.zip"
}

resource "aws_iam_role_policy" "migrate_batch_of_objects_lambda__process_objects_to_migrate_queue" {
  name   = "process-objects-to-migrate-queue"
  role   = module.migrate_batch_of_objects_lambda.service_role_name
  policy = data.aws_iam_policy_document.process_objects_to_migrate_queue.json
}

resource "aws_iam_role_policy" "migrate_batch_of_objects_lambda__read_gpaas_service_key_ssm" {
  name   = "read-gpaas-service-key-ssm"
  role   = module.migrate_batch_of_objects_lambda.service_role_name
  policy = data.aws_iam_policy_document.read_gpaas_service_key_ssm.json
}

resource "aws_iam_role_policy" "migrate_batch_of_objects_lambda__write_target_bucket" {
  name   = "write-target-bucket"
  role   = module.migrate_batch_of_objects_lambda.service_role_name
  policy = var.target_bucket_write_objects_policy_document_json
}

resource "aws_iam_role_policy" "migrate_batch_of_objects_lambda__update_objects_to_migrate_item" {
  name   = "update-objects-to-migrate-item"
  role   = module.migrate_batch_of_objects_lambda.service_role_name
  policy = data.aws_iam_policy_document.update_objects_to_migrate_item.json
}
