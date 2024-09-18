resource "aws_sfn_state_machine" "compile_objects_to_migrate" {
  name     = "compile-${var.migrator_name}-s3-objects-to-migrate"
  role_arn = aws_iam_role.rds_to_s3_sfn.arn

  definition = jsonencode({
    "Comment": "State machine to run ECS task for pg_dump",
    "StartAt": "RunEcsTask",
    "States": {
      "RunEcsTask": {
        "Type": "Task",
        "Resource": "arn:aws:states:::ecs:runTask.sync",
        "Parameters": {
          "Cluster": var.ecs_cluster_arn,
          "LaunchType": "FARGATE",
          "TaskDefinition": "${module.postgres_etl.extract_task.task_definition_arn}",
          "NetworkConfiguration": {
            "AwsvpcConfiguration": {
            "AssignPublicIp": "DISABLED",
            "SecurityGroups.$": "States.Array('${aws_security_group.restore_download_task.id}', '${aws_security_group.db_restore_fs_clients.id}')",
            "Subnets": ["${var.subnet_id}"]
            }
          }
        },
        "End": true
      }
    }
  })

  tags = {
    GPaasS3MigratorName = var.migrator_name
  }
}

resource "aws_iam_role" "rds_to_s3_sfn" {
  name = "${var.migrator_name}-rds_to_s3_sfn"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Sid = "AllowStatesAssumeRole"

        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "rds_to_s3_sfn" {
  name   = "invoke-compile-objects-to-migrate-lambda"
  role   = aws_iam_role.rds_to_s3_sfn.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:RunTask",
          ]
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}
