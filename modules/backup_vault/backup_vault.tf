resource "aws_backup_vault" "backup_vault" {
  name        = "ccs_backup_vault"
  kms_key_arn = "arn:aws:kms:${local.primary_region}:${var.backup_environment_id}:key/${var.backup_kms_key_id}"
}

resource "aws_backup_vault" "backup_vault_transfer" {
  count       = var.backup_crossregion_copy ? 1 : 0
  provider    = aws.secondary_region
  name        = "ccs_backup_vault_transfer"
  kms_key_arn = "arn:aws:kms:${local.secondary_region}:${var.backup_environment_id}:key/${var.backup_kms_key_id}"
}

resource "aws_backup_vault_policy" "backup_vault_policy" {
  backup_vault_name = aws_backup_vault.backup_vault.name
  policy            = data.aws_iam_policy_document.backup_vault_policy.json
}

resource "aws_backup_vault_policy" "backup_vault_transfer_policy" {
  provider          = aws.secondary_region
  count             = var.backup_crossregion_copy ? 1 : 0
  backup_vault_name = aws_backup_vault.backup_vault_transfer[0].name
  policy            = data.aws_iam_policy_document.backup_vault_policy.json
}
