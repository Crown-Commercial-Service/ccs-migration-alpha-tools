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

resource "aws_cloudwatch_event_target" "backup_copy_transfer" {
  rule      = aws_cloudwatch_event_rule.backup_copy_transfer.name
  target_id = "TriggerCrossAccountCopy"
  arn       = aws_lambda_function.backup_copy_to_vault.arn
}

resource "aws_lambda_permission" "backup_copy_transfer" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_copy_to_vault.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.backup_copy_transfer.arn
}
