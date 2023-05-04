data "aws_iam_policy_document" "read_cf_cred_ssm_secrets" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadCfCredsSSM"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      local.cf_password_ssm_param_arn,
      local.cf_username_ssm_param_arn
    ]
  }
}

data "aws_iam_policy_document" "read_pg_db_password_ssm_secret" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadPgPasswordSSM"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      local.pg_db_password_ssm_param_arn
    ]
  }
}
