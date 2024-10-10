resource "aws_s3_bucket" "load" {
  bucket = "${var.s3_load_bucket_name}-${var.environment_name}"

  tags = {
    Name        = var.s3_load_bucket_name
    Environment = var.environment_name
  }
}

resource "aws_s3_bucket_policy" "load" {
  bucket = aws_s3_bucket.load.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowJenkinsAccounts",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::665505400356:role/eks-paas-mountpoint-s3-csi-driver"
        },
        "Action" : "s3:*", # Adjust later
        "Resource" : [
          "${aws_s3_bucket.load.arn}",
          "${aws_s3_bucket.load.arn}/*"
        ]
      }
    ]
  })
}
