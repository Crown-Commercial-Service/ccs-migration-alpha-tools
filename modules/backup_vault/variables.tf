variable "aws_region" {
  description = "Region into which to deploy region-specific resources"
  type        = string
  default     = "eu-west-2"
}

variable "backup_copy_to_vault_runtime" {
  description = "The runtime for the Copy To Vault Lambda"
  default     = "python3.12"
  type        = string
}

variable "backup_environment_id" {
  description = "AWS ENV ID to copy backup"
  type        = string
}

variable "backup_role_name" {
  description = "Name of the IAM role to be assumed by AWS Backup for cross-account backup copying"
  type        = string
  default     = "ccs_backup_management"
}

variable "backup_kms_key_id" {
  description = "AWS ENV ID to copy backup"
  type        = string
}

variable "backup_vault_name" {
  type        = string
  description = "The name of the Airgapped Backup Vault to use for backups"
  validation {
    condition     = contains(["backup_vault_nonprod", "backup_vault_prod"], var.backup_vault_name)
    error_message = "backup_vault_name must be either 'backup_vault_nonprod' or 'backup_vault_prod'"
  }
}

variable "backup_crossregion_copy" {
  description = "Second Copy to Alt Region to replace KMS Key, and Lambda to copy into Airgapped Vault"
  type        = bool
  default     = false
}
