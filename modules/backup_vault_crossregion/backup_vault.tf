resource "aws_backup_vault" "backup_vault" {
  name        = "backup_vault"
  kms_key_arn = data.aws_kms_key.primary.arn
}

resource "aws_backup_vault" "backup_vault_transfer" {
  provider    = aws.secondary_region
  name        = "backup_vault_transfer"
  kms_key_arn = data.aws_kms_key.secondary.arn
}

resource "aws_backup_vault_policy" "backup_vault_policy" {
  backup_vault_name = aws_backup_vault.backup_vault.name
  policy            = data.aws_iam_policy_document.backup_vault_policy.json
}

resource "aws_backup_vault_policy" "backup_vault_transfer_policy" {
  provider          = aws.secondary_region
  backup_vault_name = aws_backup_vault.backup_vault_transfer.name
  policy            = data.aws_iam_policy_document.backup_vault_policy.json
}
