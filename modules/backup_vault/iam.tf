resource "aws_iam_role" "backup_role" {
  name               = var.backup_role_name
  description        = "Allows AWS Backup to access AWS resources on your behalf based on the permissions you define."
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json
}

resource "aws_iam_role" "eventbridge_cross_account_role" {
  name               = "eventbridge-cross-account-forwarder"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

resource "aws_iam_policy" "backup_kms_access" {
  name   = "backup_vault_kms_access"
  policy = data.aws_iam_policy_document.backup_kms_access.json
}

resource "aws_iam_policy" "eventbridge_cross_account_managed_policy" {
  name        = "EventBridgeCrossAccountForwarderPolicy"
  description = "Allows forwarding events to the staging account"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "events:PutEvents"
      Effect   = "Allow"
      Resource = "arn:aws:events:eu-west-1:${var.backup_environment_id}:event-bus/default"
    }]
  })
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

resource "aws_iam_role_policy_attachment" "eventbridge_cross_account_attach" {
  role       = aws_iam_role.eventbridge_cross_account_role.name
  policy_arn = aws_iam_policy.eventbridge_cross_account_managed_policy.arn
}
