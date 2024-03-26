module "create_user_task" {
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
      mounts                = []
      # N.B. $DUMP_FILENAME is injected by the Step Function task
      override_command = [
        "sh", "-c",
        "aws ssm get-parameter --name ${var.db_name}-postgres-create-tester-user-sql --query 'Parameter.Value' --output text > /tmp/create_tester_user.sql && psql -d connection_string -f /tmp/create_tester_user.sql"
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
  volumes                = []
}
