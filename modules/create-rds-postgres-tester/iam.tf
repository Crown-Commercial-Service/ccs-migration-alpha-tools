data "aws_iam_policy_document" "ssm_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.db_name}/sql_script"
    ]
  }
}

resource "aws_iam_policy" "ssm_policy" {
  name        = "SSMParameterReadPolicy"
  description = "Allows reading the value from the SSM parameter"
  policy      = data.aws_iam_policy_document.ssm_policy.json
}

resource "aws_iam_role" "step_function" {
  name = "StepFunctionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "step_function" {
  statement {
    actions = [
      "states:CreateStateMachine",
      "states:StartExecution",
      "states:DescribeExecution",
      "states:StopExecution",
      "states:GetExecutionHistory",
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.db_name}/sql_script"
    ]
  }
}

resource "aws_iam_policy" "step_funtions" {
  name        = "StepFunctionsPolicy"
  description = "Allows Step Functions to execute tasks and read SSM parameters"
  policy      = data.aws_iam_policy_document.step_function.json
}

resource "aws_iam_role_policy_attachment" "step_function" {
  role       = aws_iam_role.step_function.name
  policy_arn = aws_iam_policy.step_funtions.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task__ssm_policy" {
  role       = module.create_tester_user_task.task_role_name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParametersByPath",
      "ssm:DescribeParameters",
      "ssm:PutParameter"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.step_funtions.arn
}
