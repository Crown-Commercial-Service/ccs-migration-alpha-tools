resource "aws_lambda_function" "backup_copy_to_vault" {
  count            = var.backup_crossregion_copy ? 1 : 0
  filename         = data.archive_file.backup_copy_to_vault[0].output_path
  function_name    = "backup-copy-to-vault"
  handler          = "backup_copy_lambda.lambda_handler"
  role             = aws_iam_role.backup_role.arn
  runtime          = var.backup_copy_to_vault_runtime
  source_code_hash = data.archive_file.backup_copy_to_vault[0].output_base64sha256

  environment {
    variables = {
      AIRGAP_VAULT_ARN   = "arn:aws:backup:eu-west-2:${var.backup_environment_id}:backup-vault:${var.backup_vault_name}"
      BACKUP_ROLE_ARN    = aws_iam_role.backup_role.arn
      COPY_ORIGIN_REGION = local.secondary_region
    }
  }
}
