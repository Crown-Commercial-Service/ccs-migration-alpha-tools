data "aws_iam_policy_document" "extract_sqs" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:postgres-etl-s3.fifo"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [
        aws_s3_bucket.extract.arn,
      ]
    }
  }
}

resource "aws_sqs_queue" "extract" {
  name                        = "postgres-etl-s3.fifo"
  fifo_queue                  = true
  content_based_deduplication = true

  policy = data.aws_iam_policy_document.extract_sqs.json

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "extract_dlq" {
  name = "postgres-etl-s3-dlq"
}
