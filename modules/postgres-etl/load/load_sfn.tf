resource "aws_sfn_state_machine" "s3_to_rds" {

  name     = "${var.migrator_name}-s3-to-rds"
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
