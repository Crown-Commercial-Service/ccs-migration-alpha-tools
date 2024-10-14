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
                  "Value": "etl-dump"
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
