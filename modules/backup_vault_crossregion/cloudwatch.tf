resource "aws_cloudwatch_log_group" "lambda_backup" {
  name              = "/aws/lambda/${aws_lambda_function.backup_copy_to_vault.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "lambda_failure_alerts" {
  alarm_name          = "lambda-backup-copy-to-vault-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 3600 #hourly
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "ignore"
  alarm_description   = "Checks for Lambda errors over a 1-hour rolling window."

  dimensions = {
    FunctionName = aws_lambda_function.backup_copy_to_vault.function_name
  }

  alarm_actions = [aws_sns_topic.lambda_failure_alerts.arn]
  ok_actions    = [aws_sns_topic.lambda_failure_alerts.arn]
}
