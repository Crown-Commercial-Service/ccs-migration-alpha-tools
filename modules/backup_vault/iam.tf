resource "aws_iam_role" "backup_role" {
  name               = var.backup_role_name
  description        = "Allows AWS Backup to access AWS resources on your behalf based on the permissions you define."
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json
}

resource "aws_iam_policy" "backup_lambda_policy" {
  count       = var.backup_crossregion_copy ? 1 : 0
  name        = "backup-copy-lambda-logging-policy"
  description = "Allows the backup copy Lambda to write logs to CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_logging_permissions.json
}

resource "aws_iam_policy" "backup_kms_access" {
  name   = "backup_vault_kms_access"
  policy = data.aws_iam_policy_document.backup_kms_access.json
}

resource "aws_iam_role_policy_attachment" "backup_kms_access" {
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.backup_kms_access.arn
}

resource "aws_iam_role_policy_attachment" "backup_role_policys" {
  for_each   = local.backup_role_policy_arns
  role       = aws_iam_role.backup_role.name
  policy_arn = each.value
}
