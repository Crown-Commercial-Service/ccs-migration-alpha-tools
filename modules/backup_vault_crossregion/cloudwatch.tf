resource "aws_cloudwatch_log_group" "lambda_backup" {
  name              = "/aws/lambda/${aws_lambda_function.backup_copy_to_vault.function_name}"
  retention_in_days = 30
}
