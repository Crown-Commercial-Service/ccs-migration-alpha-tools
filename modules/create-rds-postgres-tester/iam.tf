data "aws_iam_policy_document" "ssm_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      aws_ssm_parameter.postgres_create_tester_user_sql.arn,
      var.db_connection_url_ssm_param_arn
    ]
  }
}

resource "aws_iam_policy" "ssm_policy" {
  name        = "SSMParameterReadPolicy"
  description = "Allows reading the value from the SSM parameter"
  policy      = data.aws_iam_policy_document.ssm_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task__ssm_policy" {
  role       = module.create_tester_user.task_role_name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

# resource "aws_iam_role" "ecs_task_execution" {
#   name = "ecs-task-execution-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# data "aws_iam_policy_document" "ecs_task_execution" {
#   statement {
#     actions = [
#       "ssm:GetParameter",
#       "ssm:GetParametersByPath",
#       "ssm:DescribeParameters",
#       "ssm:PutParameter"
#     ]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
#   role       = aws_iam_role.ecs_task_execution.name
#   policy_arn = aws_iam_policy.ssm_policy.arn
# }
