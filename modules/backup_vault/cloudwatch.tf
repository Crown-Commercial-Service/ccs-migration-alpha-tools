resource "aws_cloudwatch_log_group" "lambda_backup" {
  count             = var.backup_crossregion_copy ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.backup_copy_to_vault[0].function_name}"
  retention_in_days = 30
}
