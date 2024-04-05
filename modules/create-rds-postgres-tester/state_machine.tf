resource "aws_sfn_state_machine" "this" {
  name     = "create-rds-postgres-tester"
  role_arn = aws_iam_role.create_rds_postgres_tester_sfn.arn

  definition = <<EOF
{
  "StartAt": "create-rds-postgres-tester",
  "States": {
    "create-rds-postgres-tester": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "LaunchType": "FARGATE",
        "TaskDefinition": "${module.create_rds_postgres_tester.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": ["${var.subnet_id}"],
            "SecurityGroups": ["${join("\",\"", var.security_group_ids)}"],
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
