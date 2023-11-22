module "extract_task" {
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
        "apk update && apk add --no-cache postgresql-client python3 && cf install-plugin -f conduit && rm -rf $DUMP_FILENAME && cf login -a ${var.cf_config.api_endpoint} -u $CF_USERNAME -p $CF_PASSWORD -o ${var.cf_config.org} -s ${var.cf_config.space} && cf conduit --app-name ccs-${var.migrator_name}-migration-pg-dump-$RANDOM ${var.cf_config.db_service_instance} -- pg_dump -j ${var.extract_task_pgdump_workers} -Fd --file $DUMP_FILENAME --no-acl --no-owner"
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
