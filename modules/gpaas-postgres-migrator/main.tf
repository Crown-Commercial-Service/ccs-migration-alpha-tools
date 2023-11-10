resource "aws_sfn_state_machine" "perform_migration" {
  name     = "perform-${var.migrator_name}-postgres-migration"
  role_arn = aws_iam_role.sfn_perform_migration.arn

  definition = <<EOF
{
  "Comment": "Migrate a PG database from CF to RDS: ${var.migrator_name}",
  "StartAt": "Set RunOnceOnly lock",
  "States": {
    "Set RunOnceOnly lock": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:dynamodb:putItem",
      "Parameters": {
        "TableName": "${aws_dynamodb_table.migrator_lock.name}",
        "Item": {
          "Locked": {
            "S": "LOCKED"
          }
        },
        "ConditionExpression": "attribute_not_exists(Locked)"
      },
      "ResultPath": null,
      "Next": "Extract PG dump from CF"
    },
    "Extract PG dump from CF": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.extract_task.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.migrate_extract_task.id}', '${aws_security_group.db_dump_fs_clients.id}')",
            "Subnets": ["${var.subnet_id}"]
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "pg_dump",
              "Environment": [
                {
                  "Name": "DUMP_FILENAME",
                  "Value": "/mnt/efs0/${var.migrator_name}.dir"
                }
              ]
            }
          ]
        }
      },
      "ResultPath": null,
      "Next": "Load PG dump into RDS"
    },
    "Load PG dump into RDS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.load_task.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.migrate_load_task.id}', '${aws_security_group.db_dump_fs_clients.id}', '${var.db_clients_security_group_id}')",
            "Subnets": ["${var.subnet_id}"]
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "pg_restore",
              "Environment": [
                {
                  "Name": "DUMP_FILENAME",
                  "Value": "/mnt/efs0/${var.migrator_name}.dir"
                }
              ]
            }
          ]
        }
      },
      "ResultPath": null,
      "End": true
    }
  }
}
EOF

  depends_on = [
    # Some of the permissions are needed _at Terraform apply time_ hence the explicit dependency
    aws_iam_role_policy.sfn_perform_migration,
  ]

  tags = {
    GPaasPostgresMigratorName = var.migrator_name
  }
}

resource "aws_iam_role" "sfn_perform_migration" {
  name = "perform-${var.migrator_name}-migration-sfn"

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

data "aws_iam_policy_document" "sfn_perform_migration" {
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
    sid = "AllowPutMigratorLockItem"

    effect = "Allow"

    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      aws_dynamodb_table.migrator_lock.arn
    ]
  }

  statement {
    sid = "AllowRunMigratorTasks"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      "${module.extract_task.task_definition_arn_without_revision}:*",
      "${module.load_task.task_definition_arn_without_revision}:*"
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

resource "aws_iam_role_policy" "sfn_perform_migration" {
  role   = aws_iam_role.sfn_perform_migration.name
  policy = data.aws_iam_policy_document.sfn_perform_migration.json
}
