module "task_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.process_name
}

resource "aws_iam_policy" "write_logs" {
  name   = "${var.process_name}-logs-write"
  policy = module.task_log_group.write_log_group_policy_document_json
}
