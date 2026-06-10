locals {
  backup_role_policy_arns = toset([
    "arn:aws:iam::aws:policy/AWSBackupFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore",
  ])
  primary_region   = var.aws_region
  secondary_region = var.aws_region == "eu-west-2" ? "eu-west-1" : "eu-west-2"
}
