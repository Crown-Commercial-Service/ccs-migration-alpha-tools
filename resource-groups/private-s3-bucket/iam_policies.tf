data "aws_iam_policy_document" "read_objects" {
  version = "2012-10-17"

  statement {
    sid = "ListBucket${replace(var.bucket_name, "/[-_]/", "")}"

    actions = [
      "s3:ListBucket"
    ]

    effect = "Allow"

    resources = [
      aws_s3_bucket.bucket.arn
    ]
  }

  statement {
    sid = "GetObject${replace(var.bucket_name, "/[-_]/", "")}"

    actions = [
      "s3:GetObject"
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "write_objects" {
  version = "2012-10-17"

  statement {
    sid = "PutObject${replace(var.bucket_name, "/[-_]/", "")}"

    actions = [
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "delete_objects" {
  version = "2012-10-17"

  statement {
    sid = "DeleteObject${replace(var.bucket_name, "/[-_]/", "")}"

    actions = [
      "s3:DeleteObject"
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}
