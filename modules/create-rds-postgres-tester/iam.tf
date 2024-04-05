data "aws_iam_policy_document" "ssm_get" {
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

resource "aws_iam_policy" "ssm_get" {
  name        = "CreateRDSPostgresTesterSSMParameterGet"
  description = "Allows getting the value from the specified SSM parameters"
  policy      = data.aws_iam_policy_document.ssm_get.json
}

resource "aws_iam_role_policy_attachment" "ecs_task__ssm_get" {
  role       = module.create_tester_user.task_role_name
  policy_arn = aws_iam_policy.ssm_get.arn
}

# IAM resources for the Step Function
resource "aws_iam_role" "sfn_create_tester_user" {
  name = "create-tester-user-sfn"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "sfn_create_tester_user" {
  version = "2012-10-17"

  statement {
    sid = "AllowPassEcsExecRole"

    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]

    resources = [
      var.ecs_execution_role.arn,
      module.create_tester_user.task_role_arn
    ]
  }


  statement {
    sid = "AllowRunTasks"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      "${module.create_tester_user.task_definition_arn_without_revision}:*"
    ]
  }

  statement {
    sid = "AllowStopTasks"

    effect = "Allow"

    actions = [
      "ecs:DescribeTasks",
      "ecs:StopTask"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowDotSyncExecutionOfEcsTasks"

    effect = "Allow"

    actions = [
      "events:DescribeRule",
      "events:PutRule",
      "events:PutTargets"
    ]

    resources = [
      "arn:aws:events:${var.aws_region}:${var.aws_account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
    ]
  }
}

resource "aws_iam_role_policy" "sfn_create_tester_user" {
  role   = aws_iam_role.sfn_create_tester_user.name
  policy = data.aws_iam_policy_document.sfn_create_tester_user.json
}
