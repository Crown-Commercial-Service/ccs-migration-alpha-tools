module "table_rows_source" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    pg_dump = {
      cpu                   = var.extract_task_cpu
      environment_variables = []
      essential             = true
      healthcheck_command   = null
      image                 = var.cf_config.cf_cli_docker_image
      memory                = var.extract_task_memory
      mounts = [
        {
          mount_point = "/mnt/efs0"
          read_only   = false
          volume_name = "efs0"
        }
      ]
      # N.B. $DUMP_FILENAME is injected by the Step Function task
      override_command = [
        "sh", "-c",
        <<EOT
        apk update && apk add --no-cache postgresql-client python3 &&
        cf install-plugin -f conduit && rm -rf $DUMP_FILENAME &&
        cf login -a ${var.cf_config.api_endpoint} -u $CF_USERNAME -p $CF_PASSWORD -o ${var.cf_config.org} -s ${var.cf_config.space} &&
        cf conduit --app-name ccs-${var.migrator_name}-migration-pg-dump ${var.cf_config.db_service_instance} --
        psql
        %{ for table in var.count_rows_tables ~}
        -c "SELECT '${table}' AS table, COUNT(*) FROM ${table}"
        %{ endfor ~}
        %{ for table in var.estimate_rows_tables ~}
        -c "SELECT '${table}' AS table, reltuples FROM pg_class WHERE relname = '${table}'"
        %{ endfor ~}
        EOT
      ]
      port = null
      # ECS Execution role will need access to these - see aws_iam_role_policy.ecs_execution_role__read_cf_creds_ssm
      secret_environment_variables = [
        { "name" : "CF_PASSWORD", "valueFrom" : aws_ssm_parameter.cf_password.arn },
        { "name" : "CF_USERNAME", "valueFrom" : aws_ssm_parameter.cf_username.arn }
      ]
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "pg_migrate_${var.migrator_name}_extract"
  task_cpu               = var.extract_task_cpu
  task_memory            = var.extract_task_memory
  volumes = [
    {
      access_point_id = aws_efs_access_point.db_dump.id
      file_system_id  = aws_efs_file_system.db_dump.id
      volume_name     = "efs0"
    }
  ]

  depends_on = [
    aws_efs_mount_target.db_dump
  ]
}

resource "aws_security_group" "migrate_extract_task" {
  name        = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:ECSTASK:EXTRACT"
  description = "Migrator Extract task"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:ECSTASK:EXTRACT"
  }
}

resource "aws_security_group_rule" "migrate_extract_task_https_out_anywhere" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow https out from extract task to anywhere"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_extract_task.id
  to_port           = 443
  type              = "egress"
}

resource "aws_security_group_rule" "migrate_extract_task_ssh_ish_out_anywhere" {
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allows outbound ssh_ish anywhere (bespoke requirement for cf conduit)"
  # See https://github.com/alphagov/paas-cf-conduit/pull/65
  from_port         = 2222
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_extract_task.id
  to_port           = 2222
  type              = "egress"
}
