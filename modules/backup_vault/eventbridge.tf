resource "aws_cloudwatch_event_rule" "backup_copy_transfer" {
  count       = var.backup_crossregion_copy ? 1 : 0
  name        = "backup-copy-to-locked-vault"
  description = "Trigger Lambda when a backup successfully copies to the transfer vault"

  event_pattern = jsonencode({
    source        = ["aws.backup"],
    "detail-type" = ["Copy Job State Change"],
    detail = {
      state                     = ["COMPLETED"],
      destinationBackupVaultArn = [aws_backup_vault.backup_vault_transfer[0].arn]
    }
  })
}

resource "aws_cloudwatch_event_target" "backup_copy_transfer" {
  count     = var.backup_crossregion_copy ? 1 : 0
  rule      = aws_cloudwatch_event_rule.backup_copy_transfer[0].name
  target_id = "TriggerCrossAccountCopy"
  arn       = aws_lambda_function.backup_copy_to_vault[0].arn
}

resource "aws_lambda_permission" "backup_copy_transfer" {
  count         = var.backup_crossregion_copy ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_copy_to_vault[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.backup_copy_transfer[0].arn
}
