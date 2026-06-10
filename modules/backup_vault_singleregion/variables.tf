variable "aws_region" {
  description = "Region into which to deploy region-specific resources"
  type        = string
  default     = "eu-west-2"
}

variable "backup_environment_id" {
  description = "AWS ENV ID to copy backup"
  type        = string
}

variable "backup_role_name" {
  description = "Name of the IAM role to be assumed by AWS Backup for cross-account backup copying"
  type        = string
  default     = "backup_management"
}

variable "backup_kms_key_id" {
  description = "AWS ENV ID to copy backup"
  type        = string
}

variable "backup_vault_name" {
  type        = string
  description = "The name of the Airgapped Backup Vault to use for backups"
  default     = "backup_vault_locked"
}
