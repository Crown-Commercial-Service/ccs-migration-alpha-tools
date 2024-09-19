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
      image                 = var.postgres_docker_image
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
        "apk update && apk add --no-cache postgresql-client && pg_dump -d $DB_CONNECTION_URL > /mnt/efs0/$DUMP_FILENAME && aws s3 cp /mnt/efs0/$DUMP_FILENAME s3://${var.s3_bucket_name}/$DUMP_FILENAME"
      ]
      port = null
      # ECS Execution role will need access to these - see aws_iam_role_policy.ecs_execution_role__read_cf_creds_ssm
      secret_environment_variables = [
        { "name" : "DB_CONNECTION_URL", "valueFrom" : var.source_db_connection_url_ssm_param_arn }
      ]
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "pg_migrate_${var.migrator_name}_extract"
  task_cpu               = var.extract_task_cpu
  task_memory            = var.extract_task_memory
  volumes = [
    {
      access_point_id = aws_efs_access_point.db_etl.id
      file_system_id  = aws_efs_file_system.db_etl.id
      volume_name     = "efs0"
    }
  ]

  depends_on = [
    aws_efs_mount_target.db_dump
  ]
}
