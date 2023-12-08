module "lambda_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "/aws/lambda/${aws_lambda_function.function.function_name}"
}

module "cloudwatch_log_group_iam" {
  source = "../cloudwatch-log-group-iam"

  log_group_arns = [
    "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${aws_lambda_function.function.function_name}"
  ]
}
