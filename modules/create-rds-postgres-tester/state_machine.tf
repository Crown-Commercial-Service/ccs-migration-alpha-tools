resource "aws_sfn_state_machine" "create-tester-user" {
  name     = "create-tester-user"
  role_arn = aws_iam_role.sfn_create_tester_user.arn

  definition = <<EOF
{
  "StartAt": "create-tester-user",
  "States": {
    "create-tester-user": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "LaunchType": "FARGATE",
        "TaskDefinition": "${module.create_tester_user.task_definition_arn}",
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
