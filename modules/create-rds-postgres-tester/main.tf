resource "aws_sfn_state_machine" "create_rds_postgres_tester" {
  name     = "create-rds-postgres-tester"
  role_arn = aws_iam_role.step_function.arn

  definition = <<EOF
{
  "StartAt": "CreateUser",
  "States": {
    "CreateUser": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${aws_ecs_cluster.ecs_cluster.arn}",
        "LaunchType": "FARGATE",
        "TaskDefinition": "${aws_ecs_task_definition.create_user_task.arn}",
        "NetworkConfiguration": {
          "awsvpcConfiguration": {
            "Subnets": ["${var.subnet_id}"],
            "SecurityGroups": "States.Array('${var.db_clients_security_group_id}')",
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
                  "Value": "${var.target_db_connection_url_ssm_param_arn}"
                }
              ]
            }
          ]
        }
      },
    },
      "End": true
    }
  }
}
EOF
}
