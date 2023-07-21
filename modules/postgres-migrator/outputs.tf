output "read_cf_cred_ssm_secrets_policy_document_json" {
  description = "JSON describing the IAM policy which allows retrieval of CF creds from SSM"
  value       = data.aws_iam_policy_document.read_cf_cred_ssm_secrets.json
}

output "read_pg_db_password_ssm_secret_policy_document_json" {
  description = "JSON describing the IAM policy which allows retrieval of PG password from SSM"
  value       = data.aws_iam_policy_document.read_pg_db_password_ssm_secret.json
}

output "migrate_postgres_sfn_arn" {
  description = "ARN of the step function which orchestrates the extract and load processes for PG migration"
  value       = aws_sfn_state_machine.perform_migration.arn
}

output "pass_task_role_policy_document_json" {
  description = "JSON describing an IAM policy which allows passage of the ECS task role"
  value       = module.extract_task.pass_task_role_policy_document_json
}
