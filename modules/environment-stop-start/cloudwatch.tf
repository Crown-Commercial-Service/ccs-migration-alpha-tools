module "cloudwatch" {
  source = "../../../resource-groups/cloudwatch-log-group"

  log_group_name = "/aws/lambda/environment-start-stop"
  log_retention_days = 7
}
