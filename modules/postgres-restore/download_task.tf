module "download_task" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    pg_dump = {
      cpu                   = var.download_task_cpu
      environment_variables = []
      essential             = true
      healthcheck_command   = null
      image                 = var.alpine_image
      memory                = var.download_task_memory
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
        "apk update && apk add aws-cli && aws s3 cp --recursive s3://digitalmarketplace-database-backups-nft/nft-202401191508/ ."
      ]
      port = null
      # Leaving it empty for now because of the structure of the variable
      secret_environment_variables = [
        {}
      ]
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "pg_restore_${var.restore_name}_download"
  task_cpu               = var.download_task_cpu
  task_memory            = var.download_task_memory
  volumes = [
    {
      access_point_id = aws_efs_access_point.db_restore.id
      file_system_id  = aws_efs_file_system.db_restore.id
      volume_name     = "efs0"
    }
  ]

  depends_on = [
    aws_efs_mount_target.db_restore
  ]
}
