# TODO Make the "Subnets" interpolation more graceful
# TODO Prevent load process from running against a populated database
resource "aws_sfn_state_machine" "perform_migration" {
  name     = "perform-${var.process_name}-migration"
  role_arn = aws_iam_role.sfn_perform_migration.arn

  definition = <<EOF
{
  "Comment": "Migrate a PG database from CF to RDS: ${var.process_name}",
  "StartAt": "Extract PG dump from CF",
  "States": {
    "Extract PG dump from CF": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.extract_task.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.migrate_extract_task.id}', '${aws_security_group.filesystem_clients.id}')",
            "Subnets.$": "States.Array('${local.subnet_ids[0]}', '${local.subnet_ids[1]}')"
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "${var.process_name}-extract",
              "Environment": [
                {
                  "Name": "DUMP_FILENAME",
                  "Value": "${local.fs_local_mount_path}/${var.process_name}.sql"
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
            "SecurityGroups.$": "States.Array('${aws_security_group.migrate_load_task.id}', '${aws_security_group.filesystem_clients.id}', '${var.db_clients_security_group_id}')",
            "Subnets.$": "States.Array('${local.subnet_ids[0]}', '${local.subnet_ids[1]}')"
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "${var.process_name}-load",
              "Environment": [
                {
                  "Name": "DUMP_FILENAME",
                  "Value": "${local.fs_local_mount_path}/${var.process_name}.sql"
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
    # These policies are needed _at Terraform apply time_ hence the explicit dependency
    aws_iam_role_policy_attachment.sfn_perform_migration__managed_rules,
    aws_iam_role_policy_attachment.sfn_perform_migration__pass_ecs_execution_role
  ]
}

resource "aws_iam_role" "sfn_perform_migration" {
  name = "${var.process_name}-sfn"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sfn_perform_migration__pass_ecs_execution_role" {
  role       = aws_iam_role.sfn_perform_migration.id
  policy_arn = var.pass_ecs_execution_role_policy_arn
}

resource "aws_iam_policy" "manage_ecs_and_events" {
  name   = "${var.process_name}-manage-ecs-and-events"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:RunTask"
        ]
        Effect   = "Allow"
        Resource = [
          module.extract_task.task_definition_arn,
          module.load_task.task_definition_arn
        ]
      },
      {
        Action = [
          "ecs:DescribeTasks",
          "ecs:StopTask"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      # Required for the ".sync" flavour of ECS runTask invocation
      {
        Action = [
          "events:DescribeRule",
          "events:PutRule",
          "events:PutTargets"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:events:${var.aws_region}:${var.aws_account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sfn_perform_migration__managed_rules" {
  role       = aws_iam_role.sfn_perform_migration.id
  policy_arn = aws_iam_policy.manage_ecs_and_events.arn
}
