resource "aws_cloudwatch_log_group" "lambda_backup" {
  name              = "/aws/lambda/${aws_lambda_function.backup_copy_to_vault.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "lambda_failure_alerts" {
  alarm_name          = "lambda-backup-copy-to-vault-errors"
  alarm_description   = "Checks for Lambda errors over a 1-hour rolling window."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 3600
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "ignore"

  dimensions = {
    FunctionName = aws_lambda_function.backup_copy_to_vault.function_name
  }

  alarm_actions = [aws_sns_topic.backup_failure_alerts.arn]
  ok_actions    = [aws_sns_topic.backup_failure_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "backup_job_failed_alarm" {
  alarm_name          = "aws-backup-errors"
  alarm_description   = "Checks for Backup failures over a 1-hour rolling window."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfBackupJobsFailed"
  namespace           = "AWS/Backup"
  period              = 3600
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    BackupVaultName = aws_backup_vault.backup_vault.name
  }

  alarm_actions = [aws_sns_topic.backup_failure_alerts.arn]
  ok_actions    = [aws_sns_topic.backup_failure_alerts.arn]
}
