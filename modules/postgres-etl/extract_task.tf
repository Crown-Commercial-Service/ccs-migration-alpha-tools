module "extract_task" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    pg_dump = {
      cpu                   = var.extract_task_cpu
      environment_variables = [
        {
          name = "ENVIRONMENT_NAME"
          value = var.environment_name
        }
      ]
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
        "apk upgrade && rm -rf $DUMP_FILENAME && pg_dump -d $DB_CONNECTION_URL --no-acl --no-owner | gzip > $DUMP_FILENAME.gz && aws s3 cp $DUMP_FILENAME.gz s3://${var.s3_extract_bucket_name}-${var.environment_name}/etl-dump-$(date +%Y-%m-%d-%H-%M-%S).gz"
      ]
      port = null
      # ECS Execution role will need access to these
      secret_environment_variables = [
        {
          "name" : "DB_CONNECTION_URL", "valueFrom" : var.source_db_connection_url_ssm_param_arn
        }
      ]
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "${var.migrator_name}_extract"
  task_cpu               = var.extract_task_cpu
  task_memory            = var.extract_task_memory
  volumes = [
    {
      access_point_id = var.efs_access_point_id
      file_system_id  = var.efs_file_system_id
      volume_name     = "efs0"
    }
  ]

  # depends_on = [
  #   aws_efs_mount_target.db_etl
  # ]
}
