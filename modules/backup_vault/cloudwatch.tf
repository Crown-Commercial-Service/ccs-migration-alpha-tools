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

resource "aws_cloudwatch_event_rule" "catch_and_forward_backup" {
  name = "forward-backup-completion-to-management"
  event_pattern = jsonencode({
    source        = ["aws.backup"],
    "detail-type" = ["Copy Job State Change"],
    detail = {
      state                     = ["COMPLETED"],
      destinationBackupVaultArn = ["arn:aws:backup:eu-west-1:${var.backup_environment_id}:backup-vault:staging_vault"]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_to_management" {
  rule      = aws_cloudwatch_event_rule.catch_and_forward_backup.name
  target_id = "SendToManagementAccount"
  arn       = "arn:aws:events:eu-west-1:${var.backup_environment_id}:event-bus/default"
  role_arn  = aws_iam_role.eventbridge_cross_account_role.arn
}
