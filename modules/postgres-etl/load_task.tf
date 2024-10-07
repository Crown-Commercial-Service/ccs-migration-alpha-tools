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
      # N.B. $DUMP_FILENAME is injected by the Step Function task
      override_command = [
        "sh", "-c",
        "aws s3 cp s3://${var.s3_load_bucket_name}-${var.environment_name}/etl-load-$(date +%Y-%m-%d-%H-%M-%S).gz /mnt/efs0/etl-load.sql.gz && pg_restore --clean --if-exists -d $DB_CONNECTION_URL -j ${var.load_task_pgrestore_workers} --no-acl --no-owner /mnt/efs0/etl-load.sql"
      ]
      port = null
      secret_environment_variables = [
        { "name" : "DB_CONNECTION_URL", "valueFrom" : var.source_db_connection_url_ssm_param_arn }
      ]
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "pg_migrate_${var.migrator_name}_load"
  task_cpu               = var.load_task_cpu
  task_memory            = var.load_task_memory
  volumes = [
    {
      access_point_id = var.efs_access_point_id
      file_system_id  = var.efs_file_system_id
      volume_name     = "efs0"
    }
  ]
}
