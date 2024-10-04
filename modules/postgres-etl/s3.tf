resource "aws_s3_bucket" "postgres_etl" {
  bucket = "${var.s3_bucket_name}-${var.environment_name}"

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.environment_name
  }
}
