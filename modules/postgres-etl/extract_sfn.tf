resource "aws_sfn_state_machine" "rds_to_s3" {
  name     = "postgres-etl-rds-to-s3"
  role_arn = aws_iam_role.rds_to_s3_sfn.arn

  definition = <<EOF
{
  "Comment": "State machine to run ECS task for pg_dump: ${var.migrator_name}",
  "StartAt": "RunEcsTask",
  "States": {
    "RunEcsTask": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "LaunchType": "FARGATE",
        "TaskDefinition": "${module.extract_task.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
          "AssignPublicIp": "DISABLED",
          "SecurityGroups.$": "States.Array('${aws_security_group.etl_extract_task.id}', '${var.db_etl_fs_clients}', '${var.db_clients_security_group_id}')",
          "Subnets": ${jsonencode(var.subnet_ids)}
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "pg_dump",
              "Environment": [
                {
                  "Name": "DUMP_FILENAME",
                  "Value": "/mnt/efs0/etl-dump.sql"
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
    aws_iam_role_policy.rds_to_s3_sfn,
  ]

  tags = {
    GPaasS3MigratorName = var.migrator_name
  }
}

resource "aws_iam_role" "rds_to_s3_sfn" {
  name = "${var.migrator_name}_rds_to_s3_sfn"

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

data "aws_iam_policy_document" "rds_to_s3_sfn" {
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
    sid = "AllowRunPGETLTasks"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      "${module.extract_task.task_definition_arn_without_revision}:*"
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

resource "aws_iam_role_policy" "rds_to_s3_sfn" {
  role   = aws_iam_role.rds_to_s3_sfn.name
  policy = data.aws_iam_policy_document.rds_to_s3_sfn.json
}
