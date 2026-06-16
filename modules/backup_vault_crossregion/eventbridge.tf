resource "aws_cloudwatch_event_rule" "backup_copy_transfer" {
  name        = "backup-copy-to-locked-vault"
  description = "Trigger Lambda when a backup successfully copies to the transfer vault"

  event_pattern = jsonencode({
    source        = ["aws.backup"],
    "detail-type" = ["Copy Job State Change"],
    detail = {
      state                     = ["COMPLETED"],
      destinationBackupVaultArn = [aws_backup_vault.backup_vault_transfer.arn]
    }
  })
}

resource "aws_cloudwatch_event_rule" "backup_failure" {
  name        = "aws-backup-failure-monitor"
  description = "Catches failed, expired, or aborted backup, copy, and restore jobs"

  event_pattern = jsonencode({
    source = ["aws.backup"],
    "detail-type" = [
      "Backup Job State Change",
      "Copy Job State Change",
      "Restore Job State Change"
    ],
    detail = {
      state = ["FAILED", "EXPIRED", "ABORTED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "backup_copy_transfer" {
  rule      = aws_cloudwatch_event_rule.backup_copy_transfer.name
  target_id = "TriggerCrossAccountCopy"
  arn       = aws_lambda_function.backup_copy_to_vault.arn
}

resource "aws_cloudwatch_event_target" "backup_failure_sns" {
  rule      = aws_cloudwatch_event_rule.backup_failure.name
  target_id = "SendAlertToSNS"
  arn       = aws_sns_topic.backup_failure_alerts.arn
}
