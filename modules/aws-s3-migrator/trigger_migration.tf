resource "aws_pipes_pipe" "enqueue_new_objects_to_migrate" {
  name     = "${var.migrator_name}-enqueue-new-objects-to-migrate"
  role_arn = aws_iam_role.enqueue_new_objects_to_migrate_pipe.arn
  source   = aws_dynamodb_table.objects_to_migrate.stream_arn
  target   = aws_sqs_queue.objects_to_migrate.arn

  source_parameters {
    dynamodb_stream_parameters {
      batch_size        = 10
      starting_position = "LATEST"
    }

    filter_criteria {
      filter {
        pattern = jsonencode({
          eventName = ["INSERT"]
        })
      }
    }
  }

  # Pipe creation must not be attempted until these policies are in place; TF
  # will not naturally wait beyond the end of the Role creation without this block:
  depends_on = [
    aws_iam_role_policy.enqueue_new_objects_to_migrate_pipe__read_objects_to_migrate_stream,
    aws_iam_role_policy.enqueue_new_objects_to_migrate_pipe__send_new_objects_to_migrate_message
  ]
}


resource "aws_iam_role" "enqueue_new_objects_to_migrate_pipe" {
  name = "${var.migrator_name}-enqueue-migrate-pipe"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = {

      Effect = "Allow"

      Action = "sts:AssumeRole"

      Principal = {
        Service = "pipes.amazonaws.com"
      }
    }
  })
}

data "aws_iam_policy_document" "read_objects_to_migrate_stream" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadObjectsToMigrateStream"

    effect = "Allow"

    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator"
    ]

    resources = [
      aws_dynamodb_table.objects_to_migrate.stream_arn
    ]
  }

  statement {
    sid = "AllowListStreams"

    effect = "Allow"

    actions = [
      "dynamodb:ListStreams"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "enqueue_new_objects_to_migrate_pipe__read_objects_to_migrate_stream" {
  name   = "read-objects-to-migrate-stream"
  role   = aws_iam_role.enqueue_new_objects_to_migrate_pipe.name
  policy = data.aws_iam_policy_document.read_objects_to_migrate_stream.json
}

resource "aws_iam_role_policy" "enqueue_new_objects_to_migrate_pipe__send_new_objects_to_migrate_message" {
  name   = "send-new-objects-to-migrate-message"
  role   = aws_iam_role.enqueue_new_objects_to_migrate_pipe.name
  policy = data.aws_iam_policy_document.send_new_objects_to_migrate_message.json
}
