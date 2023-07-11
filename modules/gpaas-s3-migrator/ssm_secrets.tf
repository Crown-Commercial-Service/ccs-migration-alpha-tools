/* We create a dummy JSON doc and instruct the op to fill it in in
   accordance with the instructions in the README.md file in this folder.
*/
resource "aws_ssm_parameter" "gpaas_service_key" {
  name  = "gpaas-s3-service-key-${var.migrator_name}"
  type  = "SecureString"
  value = "{\"hint\":\"Populate according to the gpaas-s3-migrator/README.md instructions\"}"

  lifecycle {
    # Allow the value to be updated without reversion
    ignore_changes = [
      value
    ]
  }
}

data "aws_iam_policy_document" "read_gpaas_service_key_ssm" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadGPaasServiceKeySecret"

    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      aws_ssm_parameter.gpaas_service_key.arn
    ]
  }
}
