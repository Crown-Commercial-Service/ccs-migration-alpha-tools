resource "aws_sfn_state_machine" "perform_migration" {
  name     = "perform-${var.restore_name}-postgres-migration"
  role_arn = aws_iam_role.sfn_perform_migration.arn

  definition = <<EOF
{
  "Comment": "Migrate a PG database from CF to RDS: ${var.restore_name}",
  "StartAt": "Set RunOnceOnly lock",
  "States": {
    "Set RunOnceOnly lock": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:dynamodb:putItem",
      "Parameters": {
        "TableName": "${aws_dynamodb_table.restore_lock.name}",
        "Item": {
          "Locked": {
            "S": "LOCKED"
          }
        },
        "ConditionExpression": "attribute_not_exists(Locked)"
      },
      "ResultPath": null,
      "Next": "Get Table Row Counts and Estimates from Source"
    },
    "Get Table Row Counts and Estimates from Source": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.table_rows_source.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.migrate_download_task.id}')",
            "Subnets": ["${var.subnet_id}"]
          }
        }
      },
      "ResultPath": null,
      "Next": "Download PG dump from CF"
    },
    "Download PG dump from CF": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.download_task.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.migrate_download_task.id}', '${aws_security_group.db_restore_fs_clients.id}')",
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
                  "Value": "/mnt/efs0/${var.restore_name}.dir"
                }
              ]
            }
          ]
        }
      },
      "ResultPath": null,
      "Next": "Restore PG dump into RDS"
    },
    "Restore PG dump into RDS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.restore_task.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.migrate_restore_task.id}', '${aws_security_group.db_restore_fs_clients.id}', '${var.db_clients_security_group_id}')",
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
                  "Value": "/mnt/efs0/${var.restore_name}.dir"
                }
              ]
            }
          ]
        }
      },
      "ResultPath": null,
      "Next": "Get Table Row Counts and Estimates from Target"
    },
    "Get Table Row Counts and Estimates from Target": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.table_rows_target.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.migrate_restore_task.id}', '${var.db_clients_security_group_id}')",
            "Subnets": ["${var.subnet_id}"]
          }
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
    GPaasPostgresRestoreName = var.restore_name
  }
}

resource "aws_iam_role" "sfn_perform_migration" {
  name = "perform-${var.restore_name}-migration-sfn"

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
    sid = "AllowPutRestoreLockItem"

    effect = "Allow"

    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      aws_dynamodb_table.restore_lock.arn
    ]
  }

  statement {
    sid = "AllowRunRestoreTasks"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      "${module.table_rows_source.task_definition_arn_without_revision}:*",
      "${module.table_rows_target.task_definition_arn_without_revision}:*",
      "${module.download_task.task_definition_arn_without_revision}:*",
      "${module.restore_task.task_definition_arn_without_revision}:*"
    ]
  }

  statement {
    sid = "AllowStopRestoreTasks"

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
