resource "aws_s3_bucket" "extract" {
  bucket = "${var.s3_extract_bucket_name}-${var.environment_name}"

  tags = {
    Name        = var.s3_extract_bucket_name
    Environment = var.environment_name
  }
}

resource "aws_s3_bucket_policy" "extract" {
  bucket = aws_s3_bucket.extract.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowJenkinsToReadBucket",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::665505400356:role/eks-paas-mountpoint-s3-csi-driver"
        },
        "Action" : "s3:*", # Adjust later
        "Resource" : [
          "${aws_s3_bucket.extract.arn}",
          "${aws_s3_bucket.extract.arn}/*"
        ]
      }
    ]
  })
}


# We will not create this bucket in production, as it is only used for testing
resource "aws_s3_bucket" "load" {
  count  = var.s3_load_bucket_name != "" ? 1 : 0 # Only create the bucket if a name is provided
  bucket = "${var.s3_load_bucket_name}-${var.environment_name}"

  tags = {
    Name        = var.s3_load_bucket_name
    Environment = var.environment_name
  }
}

resource "aws_s3_bucket_policy" "load" {
  count  = var.s3_load_bucket_name != "" ? 1 : 0 # Only create the bucket if a name is provided
  bucket = aws_s3_bucket.load[0].bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowJenkinsToReadBucket",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::665505400356:role/eks-paas-mountpoint-s3-csi-driver"
        },
        "Action" : "s3:*", # Adjust later
        "Resource" : [
          "${aws_s3_bucket.load[0].arn}",
          "${aws_s3_bucket.load[0].arn}/*"
        ]
      }
    ]
  })
}
