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
      "arn:aws:sqs:*:*:postgres-etl-s3.fifo"
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
        "arn:aws:iam::665505400356:role/eks-paas-mountpoint-s3-csi-driver"
      ]
    }

    actions = [
      "sqs:*"
    ]

    resources = [
      "arn:aws:sqs:*:*:postgres-etl-s3.fifo"
    ]
  }
}

resource "aws_sqs_queue" "extract" {
  name                        = "postgres-etl-s3.fifo"
  fifo_queue                  = true
  content_based_deduplication = true

  policy = data.aws_iam_policy_document.extract_sqs.json

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.extract_dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "extract_dlq" {
  name       = "postgres-etl-s3-dlq"
  fifo_queue = true
}
