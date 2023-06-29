locals {
  container_definitions = [
    for name, vars in var.container_definitions : {
      name        = name
      command     = vars.override_command # If null, does not override Dockerfile original command
      cpu         = vars.cpu
      environment = vars.environment_variables
      essential   = vars.essential || true
      healthCheck = vars.healthcheck_command == null ? null : {
        command     = ["CMD-SHELL", vars.healthcheck_command]
        startPeriod = 10
        timeout     = 10
      }
      image = vars.image
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : module.task_log_group.log_group_name,
          "awslogs-region" : var.aws_region,
          "awslogs-stream-prefix" : "container"
        }
      }
      memory = vars.memory
      mountPoints = [
        for mount in vars.mounts :
        {
          containerPath : mount["mount_point"],
          readOnly : mount["read_only"],
          sourceVolume : mount["volume_name"]
        }
      ]
      portMappings = vars.port == null ? null : [
        {
          containerPort = vars.port
        }
      ]
      secrets = vars.secret_environment_variables
    }
  ]
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.family_name
  container_definitions    = jsonencode(local.container_definitions)
  cpu                      = var.task_cpu
  execution_role_arn       = var.ecs_execution_role_arn
  memory                   = var.task_memory
  network_mode             = "awsvpc" # Fixed for Fargate
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.task_role.arn

  dynamic "volume" {
    for_each = var.volumes
    iterator = volume

    content {
      efs_volume_configuration {
        authorization_config {
          access_point_id = volume.value["access_point_id"]
          iam             = "DISABLED"
        }
        file_system_id     = volume.value["file_system_id"]
        transit_encryption = "ENABLED"
      }

      name = volume.value["volume_name"]
    }
  }
}
