resource "aws_iam_role_policy" "ecs_execute__execution_role_permissions" {
  for_each = var.execution_role_policy_docs

  name   = "ecs-execution-permissions-${each.key}"
  role   = var.execution_role.name
  policy = each.value
}
