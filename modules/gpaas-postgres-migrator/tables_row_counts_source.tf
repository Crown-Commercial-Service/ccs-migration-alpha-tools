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
      mounts                = []
      override_command = [
        "sh", "-c",
        <<EOT
        "apk update && apk add --no-cache postgresql-client python3 &&
        cf install-plugin -f conduit && rm -rf $DUMP_FILENAME &&
        cf login -a ${var.cf_config.api_endpoint} -u $CF_USERNAME -p $CF_PASSWORD -o ${var.cf_config.org} -s ${var.cf_config.space} &&
        cf conduit --app-name ccs-${var.migrator_name}-migration-table-row-counts-$RANDOM ${var.cf_config.db_service_instance} --
        psql -c '\dt+'
        %{ for table in var.count_rows_tables ~}
        -c "SELECT '${table}' AS table, COUNT(*) FROM ${table}"
        %{ endfor ~}
        %{ for table in var.estimate_rows_tables ~}
        -c "SELECT '${table}' AS table, reltuples FROM pg_class WHERE relname = '${table}'"
        %{ endfor ~}"
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
  family_name            = "pg_migrate_${var.migrator_name}_table_row_counts"
  task_cpu               = var.extract_task_cpu
  task_memory            = var.extract_task_memory
  volumes                = []
}
