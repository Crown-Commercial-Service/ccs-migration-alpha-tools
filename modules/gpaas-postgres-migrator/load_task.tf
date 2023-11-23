locals {
  # Drops all tables first, then does the pg_restore
  # N.B. $DUMP_FILENAME is injected by the Step Function task
  load_command = <<EOF
psql -d $DB_CONNECTION_URL -c "DO \$\$
DECLARE
   tabname RECORD;
BEGIN
   FOR tabname IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename != 'spatial_ref_sys')
   LOOP
      EXECUTE 'DROP TABLE IF EXISTS ' || tabname.tablename || ' CASCADE';
   END LOOP;
END \$\$;"
&& pg_restore -d $DB_CONNECTION_URL --exit-on-error -j ${var.load_task_pgrestore_workers} --no-acl --no-owner $DUMP_FILENAME
  EOF
}

module "load_task" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    pg_restore = {
      cpu                   = var.load_task_cpu
      environment_variables = []
      essential             = true
      healthcheck_command   = null
      image                 = var.postgres_docker_image
      memory                = var.load_task_memory
      mounts = [
        {
          mount_point = "/mnt/efs0"
          read_only   = false
          volume_name = "efs0"
        }
      ]
      override_command = [
        "sh", "-c",
        replace(local.load_command, "/\\n/", " ")
      ]
      port = null
      secret_environment_variables = [
        { "name" : "DB_CONNECTION_URL", "valueFrom" : var.target_db_connection_url_ssm_param_arn }
      ]

    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "pg_migrate_${var.migrator_name}_load"
  task_cpu               = var.load_task_cpu
  task_memory            = var.load_task_memory
  volumes = [
    {
      access_point_id = aws_efs_access_point.db_dump.id
      file_system_id  = aws_efs_file_system.db_dump.id
      volume_name     = "efs0"
    }
  ]
}
