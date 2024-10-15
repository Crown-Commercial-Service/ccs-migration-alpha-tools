module "load_task" {
  source = "../../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    pg_restore = {
      cpu                   = var.load_task_cpu
      environment_variables = [
        {
          name = "ENVIRONMENT_NAME"
          value = var.environment_name
        }
      ]
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
        "aws s3 cp --quiet s3://${var.s3_load_bucket_name}-${var.environment_name}/$LOAD_FILENAME /mnt/efs0/etl-load.tar && echo \"$LOAD_FILENAME successfully downloaded from S3\" && rm -rf /mnt/efs0/etl-load && tar -xf /mnt/efs0/etl-load.tar -C /mnt/efs0 && pg_restore --clean --if-exists -d $DB_CONNECTION_URL -j ${var.load_task_pgrestore_workers} --no-acl --no-owner /mnt/efs0/etl-load"
      ]
      port = null
      secret_environment_variables = [
        { "name" : "DB_CONNECTION_URL", "valueFrom" : var.db_connection_url_ssm_param_arn }
      ]
    }
  }
  ecs_execution_role_arn = var.ecs_load_execution_role.arn
  family_name            = "${var.migrator_name}_load"
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
