module "cloudwatch_log_group_iam" {
  source = "../../resource-groups/cloudwatch-log-group-iam"

  log_group_arns = [
    "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:pg_migrate_${var.migrator_name}_extract",
    "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:pg_migrate_${var.migrator_name}_load",
    "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:pg_migrate_${var.migrator_name}_table_rows_source",
    "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:pg_migrate_${var.migrator_name}_table_rows_task"
  ]
}

# Permissions which need to be granted to the main project's ECS Execution role
#
data "aws_iam_policy_document" "migrator_policy" {
  version = "2012-10-17"
  source_policy_documents = [
    # Main ECS execution role needs access to decrypt and inject SSM params as env vars
    data.aws_iam_policy_document.read_cf_creds_ssm.json,
    module.cloudwatch_log_group_iam.write_log_group_policy_document_json
  ]
}

resource "aws_iam_role_policy" "ecs_execution_role__migrator_policy" {
  name   = "${var.migrator_name}-migrator-policy"
  role   = var.ecs_execution_role.name
  policy = data.aws_iam_policy_document.migrator_policy.json
}
