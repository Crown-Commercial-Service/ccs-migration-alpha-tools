module "load_task" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    psql = {
      cpu                   = 2048
      environment_variables = []
      essential             = true
      healthcheck_command   = null
      image                 = var.postgres_docker_image
      memory                = 4096
      mounts = [
        {
          mount_point = "/mnt/efs0"
          read_only   = true
          volume_name = "efs0"
        }
      ]
      # N.B. $DUMP_FILENAME is injected by the Step Function task
      override_command = [
        "sh", "-c",
        "psql $DB_CONNECTION_URL < $DUMP_FILENAME"
      ]
      port = null
      secret_environment_variables = [
        { "name" : "DB_CONNECTION_URL", "valueFrom" : var.target_db_connection_url_ssm_param_arn }
      ]

    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "pg_migrate_${var.migrator_name}_load"
  task_cpu               = 2048
  task_memory            = 4096
  volumes = [
    {
      access_point_id = aws_efs_access_point.db_dump.id
      file_system_id  = aws_efs_file_system.db_dump.id
      volume_name     = "efs0"
    }
  ]
}

resource "aws_security_group" "migrate_load_task" {
  name        = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:ECSTASK:LOAD"
  description = "Migrator Load task"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:ECSTASK:LOAD"
  }
}

resource "aws_security_group_rule" "migrate_load_task_https_out_anywhere" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow https out from load task to anywhere"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_load_task.id
  to_port           = 443
  type              = "egress"
}
