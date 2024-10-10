# Permissions which need to be granted to the main project's ECS Execution role
#
data "aws_iam_policy_document" "postgres_etl" {
  version = "2012-10-17"
  # We are expecting repeated Sids of "DescribeAllLogGroups", hence `overwrite` rather than `source`
  override_policy_documents = [
    # Main ECS execution role needs access to decrypt and inject SSM params as env vars
    data.aws_iam_policy_document.etl_policy.json,
    data.aws_iam_policy_document.read_creds_ssm.json,
    module.extract_task.write_task_logs_policy_document_json,
    # module.load_task.write_task_logs_policy_document_json,
    var.environment_name == "production" ? null : module.load_task.write_task_logs_policy_document_json
  ]
}

resource "aws_iam_role_policy" "ecs_execution_role__postgres_etl_extract" {
  name   = "pg-etl-policy-extract"
  role   = var.ecs_extract_execution_role.name
  policy = data.aws_iam_policy_document.postgres_etl.json
}

resource "aws_iam_role_policy" "bucket_access__postgres_etl_extract" {
  name   = "bucket_access_extract"
  role   = var.ecs_extract_execution_role.name
  policy = data.aws_iam_policy_document.bucket_access.json
}

resource "aws_iam_role_policy" "ecs_exec_policy__postgres_etl_extract" {
  name   = "ecs_exec_policy_extract"
  role   = var.ecs_extract_execution_role.name
  policy = data.aws_iam_policy_document.ecs_exec_policy.json
}

resource "aws_iam_role_policy" "ecs_execution_role__postgres_etl_load" {
  count = var.environment_name == "production" ? 0 : 1 # This policy is skipped in production

  name   = "pg-etl-policy-load"
  role   = var.ecs_load_execution_role.name
  policy = data.aws_iam_policy_document.postgres_etl.json
}

resource "aws_iam_role_policy" "bucket_access__postgres_etl_load" {
  count = var.environment_name == "production" ? 0 : 1 # This policy is skipped in production

  name   = "bucket_access_load"
  role   = var.ecs_load_execution_role.name
  policy = data.aws_iam_policy_document.bucket_access.json
}

resource "aws_iam_role_policy" "ecs_exec_policy__postgres_etl_load" {
  count = var.environment_name == "production" ? 0 : 1 # This policy is skipped in production

  name   = "ecs_exec_policy_load"
  role   = var.ecs_load_execution_role.name
  policy = data.aws_iam_policy_document.ecs_exec_policy.json
}
