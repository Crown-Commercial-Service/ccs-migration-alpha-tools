# Permissions which need to be granted to the main project's ECS Execution role
#
data "aws_iam_policy_document" "migrator_policy" {
  version = "2012-10-17"
  # We are expecting repeated Sids of "DescribeAllLogGroups", hence `overwrite` rather than `source`
  override_policy_documents = [
    # Main ECS execution role needs access to decrypt and inject SSM params as env vars
    data.aws_iam_policy_document.read_cf_creds_ssm.json,
    module.table_rows_source.write_task_logs_policy_document_json,
    module.table_rows_target.write_task_logs_policy_document_json,
    module.extract_task.write_task_logs_policy_document_json,
    module.load_task.write_task_logs_policy_document_json,
  ]
}

resource "aws_iam_role_policy" "ecs_execution_role__migrator_policy" {
  name   = "${var.migrator_name}-migrator-policy"
  role   = var.ecs_execution_role.name
  policy = data.aws_iam_policy_document.migrator_policy.json
}
