module "load_task" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    load = {
      cpu                   = 2048
      environment_variables = []
      essential             = true
      healthcheck_command   = null
      image                 = var.pg_docker_image
      memory                = 4096
      mounts = [
        {
          mount_point = local.fs_local_mount_path
          read_only   = true
          volume_name = "efs0"
        }
      ]
      override_command = [
        "sh", "-c",
        "psql postgres://${var.pg_db_username}:$PG_PASSWORD@${var.pg_db_endpoint}/${var.pg_db_name} < $DUMP_FILENAME"
      ]
      port = null
      secret_environment_variables = [
        { "name" : "PG_PASSWORD", "valueFrom" : var.pg_db_password_ssm_param }
      ]

    }
  }
  ecs_execution_role_arn = var.ecs_execution_role_arn
  family_name            = "${var.process_name}-load"
  task_cpu               = 2048
  task_memory            = 4096
}

resource "aws_security_group" "migrate_load_task" {
  name        = "${var.process_name}-load-task" # TODO rename
  description = "Security rules for the ${var.process_name}-load task"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "migrate_load_https_out_anywhere" {
  description = "Allows outbound https anywhere"

  cidr_blocks = [
    "0.0.0.0/0"
  ]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_load_task.id
  to_port           = 443
  type              = "egress"
}
