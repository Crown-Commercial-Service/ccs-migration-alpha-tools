module "lambda_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "/aws/lambda/${aws_lambda_function.function.function_name}"
}
