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

  dist_folder_path      = "${path.module}/lambdas/dist"
  dist_package_filename = "migrate_batch_of_objects.zip"
  dist_package_hash = {
    base64sha256 = data.archive_file.migrate_batch_of_objects_lambda_zip.output_base64sha256
    md5          = data.archive_file.migrate_batch_of_objects_lambda_zip.output_md5
  }
  environment_variables = {
    S3_SERVICE_KEY_SSM_PARAM_NAME = aws_ssm_parameter.s3_service_key.name
    TARGET_BUCKET_ID              = var.target_bucket_id
    TRANSFER_LIST_TABLE_NAME      = aws_dynamodb_table.objects_to_migrate.name
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

data "aws_iam_policy_document" "write_objects" {
  version = "2012-10-17"

  statement {
    sid = "PutObject${replace(var.target_bucket_id, "/[-_]/", "")}"

    actions = [
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.target_bucket_id}/*",
    ]
  }
}

resource "aws_iam_role_policy" "migrate_batch_of_objects_lambda__write_target_bucket" {
  name   = "write-target-bucket"
  role   = module.migrate_batch_of_objects_lambda.service_role_name
  policy = data.aws_iam_policy_document.write_objects.json
}

resource "aws_iam_role_policy" "migrate_batch_of_objects_lambda__update_objects_to_migrate_item" {
  name   = "update-objects-to-migrate-item"
  role   = module.migrate_batch_of_objects_lambda.service_role_name
  policy = data.aws_iam_policy_document.update_objects_to_migrate_item.json
}

resource "aws_iam_role_policy" "migrate_batch_of_objects_lambda__read_s3_service_key_ssm" {
  name   = "read-s3-service-key-ssm-migrate"
  role   = module.migrate_batch_of_objects_lambda.service_role_name
  policy = data.aws_iam_policy_document.read_s3_service_key_ssm.json
}

data "aws_iam_policy_document" "download_objects_in_s3_bucket" {
  version = "2012-10-17"

  statement {
    sid = "AllowListS3Objects"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      format("arn:aws:s3:::%s", var.source_bucket.bucket_name),
      format("arn:aws:s3:::%s/*", var.source_bucket.bucket_name)
    ]
  }
}

resource "aws_iam_role_policy" "migrate_batch_of_objects_lambda__download_objects_in_s3_bucket" {
  name   = "download_objects_in_s3_bucket"
  role   = module.migrate_batch_of_objects_lambda.service_role_name
  policy = data.aws_iam_policy_document.download_objects_in_s3_bucket.json
}
