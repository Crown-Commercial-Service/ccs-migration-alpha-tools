resource "aws_sfn_state_machine" "create_rds_postgres_tester" {
  name     = "create-rds-postgres-tester"
  role_arn = aws_iam_role.step_function.arn

  definition = <<EOF
{
  "StartAt": "RetrieveSSMParameter",
  "States": {
    "RetrieveSSMParameter": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ssm:getParameter",
      "Parameters": {
        "Name": "/${var.db_name}/sql_script",
        "WithDecryption": true
        },
        "Next": "CreateUser"
      },
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
              "SecurityGroups": ["${aws_security_group.ecs_security_group.id}"],
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
        "End": true
      },
      "End": true
    }
  }
}
EOF
}
