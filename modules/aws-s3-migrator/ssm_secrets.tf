/* We create a JSON doc.
*/
resource "aws_ssm_parameter" "s3_service_key" {
  name  = "s3-service-key-${var.migrator_name}"
  type  = "SecureString"
  value = jsonencode(var.source_bucket)
}

data "aws_iam_policy_document" "read_s3_service_key_ssm" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadS3ServiceKeySecret"

    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      aws_ssm_parameter.s3_service_key.arn
    ]
  }
}
