module "create_rds_postgres_tester" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    pg_create_user = {
      cpu                   = var.create_rds_postgres_tester_task_cpu
      environment_variables = []
      essential             = true
      healthcheck_command   = null
      image                 = var.postgres_docker_image
      memory                = var.create_rds_postgres_tester_task_memory
      mounts                = []
      # Requires use of an Alpine-based image, to install the AWS CLI to fetch the SQL from SSM
      override_command = [
        "sh", "-c",
        "apk add --no-cache aws-cli > /dev/null 2>&1 && aws ssm get-parameter --name ${var.db_name}-create-rds-postgres-tester-sql --query 'Parameter.Value' --output text > /tmp/create_rds_postgres_tester.sql && psql -d $DB_CONNECTION_URL -f /tmp/create_rds_postgres_tester.sql"
      ]
      port = null
      secret_environment_variables = [
        { "name" : "DB_CONNECTION_URL", "valueFrom" : var.db_connection_url_ssm_param_arn }
      ]
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "${var.db_name}-postgres-create-tester-user"
  task_cpu               = var.create_rds_postgres_tester_task_cpu
  task_memory            = var.create_rds_postgres_tester_task_memory
  volumes                = []
}
