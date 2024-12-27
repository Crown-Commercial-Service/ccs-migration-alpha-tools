resource "aws_s3_bucket" "extract" {
  bucket = "${var.s3_extract_bucket_name}-${var.environment_name}"

  tags = {
    Name        = var.s3_extract_bucket_name
    Environment = var.environment_name
  }
}

resource "aws_s3_bucket_notification" "extract" {
  bucket = aws_s3_bucket.extract.bucket

  queue {
    queue_arn     = aws_sqs_queue.extract.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".tar"
  }
}

resource "aws_s3_bucket_policy" "extract" {
  bucket = aws_s3_bucket.extract.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowJenkinsAccounts",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::473251818902:role/eks-paas-postgres-etl", # Dev
            "arn:aws:iam::665505400356:role/eks-paas-postgres-etl", # SBX
            "arn:aws:iam::974531504241:role/eks-paas-postgres-etl"  # PROD
          ]
        },
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetObjectTagging"
        ],
        "Resource" : [
          "${aws_s3_bucket.extract.arn}",
          "${aws_s3_bucket.extract.arn}/*"
        ]
      }
    ]
  })
}
