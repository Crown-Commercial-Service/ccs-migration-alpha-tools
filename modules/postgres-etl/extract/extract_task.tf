module "extract_task" {
  source = "../../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    pg_dump = {
      cpu                   = var.extract_task_cpu
      environment_variables = [
        {
          name = "ENVIRONMENT_NAME"
          value = var.environment_name
        },
        {
          name = "MOUNT_POINT"
          value = "/mnt/efs0"
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
        "apk upgrade && rm -rf $MOUNT_POINT/$DUMP_FILENAME && pg_dump -d $DB_CONNECTION_URL -Fd -j ${var.extract_task_pgrestore_workers} --no-acl --no-owner -f $MOUNT_POINT/$DUMP_FILENAME && echo \"Database successfully dumped\" && tar -C $MOUNT_POINT -cf $MOUNT_POINT/$DUMP_FILENAME.tar $DUMP_FILENAME && echo \"Archive successfully created\" && aws aws s3 cp --quiet $MOUNT_POINT/$DUMP_FILENAME.tar s3://${var.s3_extract_bucket_name}-${var.environment_name}/$DUMP_FILENAME-$(date +%Y-%m-%d-%H-%M-%S)_$LOAD_ENVIRONMENT.tar && aws s3api put-object-tagging --bucket ${var.s3_extract_bucket_name} --tagging 'TagSet=[{Key=ExecutionID,Value=$EXECUTION_ID}]' --key $DUMP_FILENAME-$(date +%Y-%m-%d-%H-%M-%S)_$LOAD_ENVIRONMENT.tar && echo \"$DUMP_FILENAME successfully uploaded to S3\""
      ]
      port = null
      # ECS Execution role will need access to these
      secret_environment_variables = [
        {
          "name" : "DB_CONNECTION_URL", "valueFrom" : var.db_connection_url_ssm_param_arn
        }
      ]
    }
  }
  ecs_execution_role_arn = var.ecs_extract_execution_role.arn
  family_name            = "${var.migrator_name}-extract"
  task_cpu               = var.extract_task_cpu
  task_memory            = var.extract_task_memory
  volumes = [
    {
      access_point_id = var.efs_access_point_id
      file_system_id  = var.efs_file_system_id
      volume_name     = "efs0"
    }
  ]
}
