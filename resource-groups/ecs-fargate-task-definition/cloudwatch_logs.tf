module "task_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.family_name
}
