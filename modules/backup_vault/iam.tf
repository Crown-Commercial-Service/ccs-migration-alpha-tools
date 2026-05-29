resource "aws_iam_role" "backup_role" {
  name               = var.backup_role_name
  description        = "Allows AWS Backup to access AWS resources on your behalf based on the permissions you define."
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json
}

resource "aws_iam_role" "eventbridge_forwarder_role" {
  name               = "eventbridge-cross-account-forwarder"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

resource "aws_iam_policy" "backup_kms_access" {
  name   = "backup_vault_kms_access"
  policy = data.aws_iam_policy_document.backup_kms_access.json
}

resource "aws_iam_policy" "eventbridge_forwarder_policy" {
  name        = "EventBridgeCrossAccountForwarderPolicy"
  description = "Allows forwarding events to the staging account"
  policy      = data.aws_iam_policy_document.eventbridge_forwarder_policy.json
}

resource "aws_iam_role_policy_attachment" "backup_kms_access" {
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.backup_kms_access.arn
}

resource "aws_iam_policy" "backup_lambda_policy" {
  count       = var.backup_crossregion_copy ? 1 : 0
  name        = "backup-copy-lambda-logging-policy"
  description = "Allows the backup copy Lambda to write logs to CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_logging_permissions.json
}

resource "aws_iam_role_policy_attachment" "backup_role_policys" {
  for_each   = local.backup_role_policy_arns
  role       = aws_iam_role.backup_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "eventbridge_cross_account_attach" {
  role       = aws_iam_role.eventbridge_forwarder_role.name
  policy_arn = aws_iam_policy.eventbridge_cross_account_managed_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  count      = var.backup_crossregion_copy ? 1 : 0
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.backup_lambda_policy[0].arn
}
