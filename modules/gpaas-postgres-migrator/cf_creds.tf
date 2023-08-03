/* We create dummy SSM parameters and instruct the op to fill then in in
   accordance with the instructions in the README.md file in this folder.
*/
resource "aws_ssm_parameter" "cf_username" {
  name        = "cf-username-postgres-migrator-${var.migrator_name}"
  description = "Username for a CF account which will enable access to the source environment for the migration"
  type        = "SecureString"
  value       = "Populate according to the gpaas-postgres-migrator/README.md instructions"

  lifecycle {
    # Allow the value to be updated without reversion
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "cf_password" {
  name        = "cf-password-postgres-migrator-${var.migrator_name}"
  description = "Password for a CF account which will enable access to the source environment for the migration"
  type        = "SecureString"
  value       = "Populate according to the gpaas-postgres-migrator/README.md instructions"

  lifecycle {
    # Allow the value to be updated without reversion
    ignore_changes = [
      value
    ]
  }
}

data "aws_iam_policy_document" "read_cf_creds_ssm" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadCfCredsSecrets"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      aws_ssm_parameter.cf_password.arn,
      aws_ssm_parameter.cf_username.arn,
    ]
  }
}
