resource "aws_sfn_state_machine" "s3_to_rds" {
  count = var.environment_name == "production" ? 0 : 1 # This state machine is skipped in production

  name     = "postgres-etl-s3-to-rds"
  role_arn = aws_iam_role.s3_to_rds_sfn.arn

  definition = <<EOF
{
  "Comment": "State machine to run ECS task for pg_restore: ${var.migrator_name}",
  "StartAt": "LoadCleanedPGDumpIntoTargetDatabase",
  "States": {
    "LoadCleanedPGDumpIntoTargetDatabase": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.load_task.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.etl_load_task.id}', '${var.db_etl_fs_clients}', '${var.db_clients_security_group_id}')",
            "Subnets": ${jsonencode(var.subnet_ids)}
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "pg_restore",
              "Environment": [
                {
                  "Name": "LOAD_FILENAME",
                  "Value.$": "$.LOAD_FILENAME"
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

  depends_on = [
    # Some of the permissions are needed _at Terraform apply time_ hence the explicit dependency
    aws_iam_role_policy.s3_to_rds_sfn,
  ]

  tags = {
    GPaasS3MigratorName = var.migrator_name
  }
}

resource "aws_iam_role" "s3_to_rds_sfn" {
  count = var.environment_name == "production" ? 0 : 1 # This role is skipped in production

  name = "${var.migrator_name}_s3_to_rds_sfn"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Sid = "AllowStatesAssumeRole"

        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "s3_to_rds_sfn" {
  count = var.environment_name == "production" ? 0 : 1 # This policy is skipped in production

  version = "2012-10-17"

  statement {
    sid = "AllowPassEcsExecRole"

    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]

    resources = [
      var.ecs_load_execution_role.arn,
    ]
  }

  statement {
    sid = "AllowRunPGETLTasks"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      "${module.load_task.task_definition_arn_without_revision}:*"
    ]
  }

  statement {
    sid = "AllowStopPGETLTasks"

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

resource "aws_iam_role_policy" "s3_to_rds_sfn" {
  count = var.environment_name == "production" ? 0 : 1 # This policy is skipped in production

  role   = aws_iam_role.s3_to_rds_sfn.name
  policy = data.aws_iam_policy_document.s3_to_rds_sfn.json
}