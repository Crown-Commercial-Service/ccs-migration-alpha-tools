resource "aws_sqs_queue" "objects_to_migrate" {
  name = "${var.migrator_name}-objects-to-migrate"
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
