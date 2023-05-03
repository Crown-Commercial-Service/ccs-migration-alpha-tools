module "application_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.service_name}-application"
}

resource "aws_iam_policy" "write_application_logs" {
  name   = "${var.service_name}-application-logs-write"
  policy = module.application_log_group.write_log_group_policy_document_json
}

resource "aws_iam_role_policy_attachment" "task_role__write_application_logs" {
  role       = module.service_task_definition.task_role_name
  policy_arn = aws_iam_policy.write_application_logs.arn
}

module "container_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.service_name}-container"
}

module "nginx_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.service_name}-nginx"
}

resource "aws_iam_policy" "write_nginx_logs" {
  name   = "${var.service_name}-nginx-logs-write"
  policy = module.nginx_log_group.write_log_group_policy_document_json
}

resource "aws_iam_role_policy_attachment" "task_role__write_nginx_logs" {
  role       = module.service_task_definition.task_role_name
  policy_arn = aws_iam_policy.write_nginx_logs.arn
}
