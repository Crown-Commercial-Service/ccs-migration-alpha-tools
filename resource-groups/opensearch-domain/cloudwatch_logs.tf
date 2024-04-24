module "search_slow_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_search_slow_logs
}

module "index_slow_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_index_slow_logs
}

module "error_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_error_logs
}

module "audit_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_audit_logs
}