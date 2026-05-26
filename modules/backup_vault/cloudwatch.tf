resource "aws_cloudwatch_log_group" "lambda_backup" {
  count             = var.backup_crossregion_copy ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.backup_copy_to_vault[0].function_name}"
  retention_in_days = 30
}

resource "aws_iam_policy" "backup_lambda_policy" {
  count       = var.backup_crossregion_copy ? 1 : 0
  name        = "backup-copy-lambda-logging-policy"
  description = "Allows the backup copy Lambda to write logs to CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_logging_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  count      = var.backup_crossregion_copy ? 1 : 0
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.backup_lambda_policy[0].arn
}
