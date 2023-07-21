module "postgres_migrator" {
  source = "../modules/postgres-migrator"

  aws_account_id                     = "123456789012"
  aws_region                         = "us-east-1"
  cf_api_endpoint                    = "https://some.endpoint"
  cf_cli_docker_image                = "docker/cf-cli"
  cf_org                             = "acme"
  cf_password_ssm_param              = "cf_password_secret"
  cf_service_instance                = "postgres"
  cf_space                           = "dev"
  cf_username_ssm_param              = "cf_username_secret"
  db_clients_security_group_id       = "sg-12345"
  ecs_cluster_arn                    = "arn:aws::::::"
  ecs_execution_role_arn             = "arn:aws::::::"
  pass_ecs_execution_role_policy_arn = "arn:aws::::::"
  pg_db_endpoint                     = "1234567.us-east-1.rds.amazonaws.com:5432"
  pg_db_name                         = "db"
  pg_db_password_ssm_param           = "db_password_secret"
  pg_db_username                     = "postgres"
  pg_docker_image                    = "postgres:latest"
  process_name                       = "migrate"
  resource_name_prefixes = {
    normal        = "PREFIX:123"
    hyphens       = "PREFIX-123"
    hyphens_lower = "prefix-n123"
  }
  subnets = {
    "us-east-1a" = "subnet-1234",
    "us-east-1b" = "subnet-5678"
  }
  vpc_id = "vpc-12345"
}
