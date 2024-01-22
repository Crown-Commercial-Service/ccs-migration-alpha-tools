resource "aws_sfn_state_machine" "perform_restore" {
  name     = "perform-${var.restore_name}-postgres-restore"
  role_arn = aws_iam_role.sfn_perform_restore.arn

  definition = <<EOF
{
  "Comment": "Restore a PG database from S3 to RDS: ${var.restore_name}",
  "StartAt": "Copy files from S3",
  "States": {
    "Copy files from S3": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.download_task.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.restore_download_task.id}', '${aws_security_group.db_restore_fs_clients.id}')",
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
                  "Value": "/mnt/efs0/nft-202401212100/"
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
            "SecurityGroups.$": "States.Array('${aws_security_group.restore_task.id}', '${aws_security_group.db_restore_fs_clients.id}', '${var.db_clients_security_group_id}')",
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
                  "Value": "/mnt/efs0/nft-202401212100/"
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
    aws_iam_role_policy.sfn_perform_restore,
  ]

  tags = {
    GPaasPostgresRestoreName = var.restore_name
  }
}

resource "aws_iam_role" "sfn_perform_restore" {
  name = "perform-${var.restore_name}-restore-sfn"

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

data "aws_iam_policy_document" "sfn_perform_restore" {
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
    sid = "AllowRunRestoreTasks"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
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

resource "aws_iam_role_policy" "sfn_perform_restore" {
  role   = aws_iam_role.sfn_perform_restore.name
  policy = data.aws_iam_policy_document.sfn_perform_restore.json
}
