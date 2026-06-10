resource "aws_backup_vault" "backup_vault" {
  name        = "backup_vault"
  kms_key_arn = data.aws_kms_key.primary.arn
}

resource "aws_backup_vault_policy" "backup_vault_policy" {
  backup_vault_name = aws_backup_vault.backup_vault.name
  policy            = data.aws_iam_policy_document.backup_vault_policy.json
}
