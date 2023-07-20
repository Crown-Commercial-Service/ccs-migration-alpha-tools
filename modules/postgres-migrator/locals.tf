locals {
  /* Note that for the SSM parameters holding the cf access creds, we assemble the ARNs here rather than look
     them up using an aws_ssm_parameter data source. This is because we want to be able to apply the Terraform
     without having to make sure the SSM params are in place beforehand. This way the parameters only need to
     be specified ahead of runtime of the migration task.
  */
  cf_password_ssm_param_arn    = "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.cf_password_ssm_param}"
  cf_username_ssm_param_arn    = "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.cf_username_ssm_param}"
  fs_local_mount_path          = "/mnt/efs0"
  nfs_port                     = 2049
  pg_db_password_ssm_param_arn = "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.pg_db_password_ssm_param}"
  subnet_ids                   = [for az, id in var.subnets : id]
}
