data "aws_iam_policy_document" "extract_sqs" {
  statement {
    effect = "Allow"

    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      "arn:aws:sqs:*:*:postgres-etl-s3"
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        aws_s3_bucket.extract.arn,
      ]
    }
  }

  # Allow the SQS queue to be used by the Jenkins account
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::665505400356:role/eks-paas-postgres-etl"
      ]
    }

    actions = [
      "sqs:*"
    ]

    resources = [
      "arn:aws:sqs:*:*:postgres-etl-s3"
    ]
  }
}

resource "aws_sqs_queue" "extract" {
  name = "${var.migrator_name}-s3"

  policy = data.aws_iam_policy_document.extract_sqs.json

  receive_wait_time_seconds = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.extract_dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "extract_dlq" {
  name = "${var.migrator_name}-s3-dlq"
}
