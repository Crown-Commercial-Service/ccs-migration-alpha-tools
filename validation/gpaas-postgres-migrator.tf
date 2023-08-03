module "gpaas_postgres_migrator" {
  source = "../modules/gpaas-postgres-migrator"

  aws_account_id = "123456789012"
  aws_region     = "us-east-1"
  cf_config = {
    api_endpoint        = "https://api.london.cloud.service.gov.uk"
    cf_cli_docker_image = "governmentpaas/cf-cli"
    db_service_instance = "instance01"
    org                 = "org1"
    space               = "space1"
  }
  db_clients_security_group_id = "sg-1234567890"
  ecs_cluster_arn              = "arn:aws:ecs:eu-west-2:123456789012:cluster/MAINAPP"
  ecs_execution_role = {
    arn  = "arn:aws:iam::123456789012:role/Project_Deployment"
    name = "Project_Deployment"
  }
  migrator_name         = "migratoo000r"
  postgres_docker_image = "postgres:latest"
  resource_name_prefixes = {
    normal        = "PROJ:EUW2:DEV",
    hyphens       = "PROJ-EUW2-DEV",
    hyphens_lower = "proj-euw2-dev"
  }
  subnet_id                              = "subnet-0123456789"
  target_db_connection_url_ssm_param_arn = "arn:aws:ssm:eu-west-2:123456789012:parameter/connection_url"
  vpc_id                                 = "vpc-1234"
}
