module "cloudwatch_log_group" {
  source = "../resource-groups/cloudwatch-log-group"

  log_group_name     = "log-group"
  log_retention_days = 14
}
