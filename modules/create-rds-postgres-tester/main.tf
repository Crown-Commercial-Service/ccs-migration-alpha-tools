resource "aws_sfn_state_machine" "create-tester-user" {
  name     = "perform-create-tester-user"
  role_arn = aws_iam_role.sfn_create_tester_user.arn

  definition = <<EOF
{
  "StartAt": "create-tester-user",
  "States": {
    "create-tester-user": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "LaunchType": "FARGATE",
        "TaskDefinition": "${module.create_tester_user.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": ["${var.subnet_id}"],
            "SecurityGroups": ["${var.db_clients_security_group_id}"],
            "AssignPublicIp": "ENABLED"
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "pg_create_user",
              "Environment": [
                {
                  "Name": "DB_CONNECTION_URL",
                  "Value": "${var.db_connection_url_ssm_param_arn}"
                }
              ]
            }
          ]
        }
      },
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role" "sfn_create_tester_user" {
  name = "perform-create-tester-user-sfn"

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

data "aws_iam_policy_document" "sfn_perform_create_tester_user" {
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
    ]
  }


  statement {
    sid = "AllowRunMigratorTasks"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      "${module.create_tester_user.task_definition_arn_without_revision}:*"
    ]
  }

  statement {
    sid = "AllowStopMigratorTasks"

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
