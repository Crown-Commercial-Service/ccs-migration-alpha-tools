resource "aws_iam_policy" "execution_role_permissions" {
  for_each = var.execution_role_policy_docs

  name   = "ecs-execution-permissions-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "ecs_execute__execution_role_permissions" {
  for_each = aws_iam_policy.execution_role_permissions

  role       = var.execution_role.name
  policy_arn = each.value.arn
}
