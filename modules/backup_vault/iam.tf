resource "aws_iam_role" "backup_role" {
  name               = var.backup_role_name
  description        = "Allows AWS Backup to access AWS resources on your behalf based on the permissions you define."
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json
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

resource "aws_iam_role_policy_attachment" "backup_role_policys" {
  for_each   = local.backup_role_policy_arns
  role       = aws_iam_role.backup_role.name
  policy_arn = each.value
}
