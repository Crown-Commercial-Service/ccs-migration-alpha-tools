data "aws_iam_policy_document" "read_creds_ssm" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadCredsSecrets"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      var.source_db_connection_url_ssm_param_arn
    ]
  }
}
