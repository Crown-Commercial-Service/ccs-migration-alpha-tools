module "extract" {
  source = "./extract"

  count = var.enable_extract ? 1 : 0

  aws_account_id                  = var.aws_account_id
  aws_region                      = var.aws_region
  db_clients_security_group_id    = var.db_clients_security_group_id
  db_etl_fs_clients               = var.db_etl_fs_clients
  efs_access_point_id             = var.efs_access_point_id
  efs_file_system_id              = var.efs_file_system_id
  ecs_extract_execution_role_arn  = var.ecs_extract_execution_role_arn
  ecs_extract_execution_role_name = var.ecs_extract_execution_role_name
  ecs_cluster_arn                 = var.ecs_cluster_arn
  postgres_docker_image           = var.postgres_docker_image
  environment_name                = var.environment_name
  migrator_name                   = var.migrator_name
  resource_name_prefixes          = var.resource_name_prefixes
  db_connection_url_ssm_param_arn = var.db_connection_url_ssm_param_arn
  s3_extract_bucket_name          = var.s3_extract_bucket_name
  subnet_ids                      = var.subnet_ids
  vpc_id                          = var.vpc_id
}

module "load" {
  source = "./load"

  count = var.enable_load ? 1 : 0

  aws_account_id                  = var.aws_account_id
  aws_region                      = var.aws_region
  db_clients_security_group_id    = var.db_clients_security_group_id
  db_etl_fs_clients               = var.db_etl_fs_clients
  efs_access_point_id             = var.efs_access_point_id
  efs_file_system_id              = var.efs_file_system_id
  ecs_load_execution_role_arn     = var.ecs_load_execution_role_arn
  ecs_load_execution_role_name    = var.ecs_load_execution_role_name
  ecs_cluster_arn                 = var.ecs_cluster_arn
  postgres_docker_image           = var.postgres_docker_image
  environment_name                = var.environment_name
  migrator_name                   = var.migrator_name
  resource_name_prefixes          = var.resource_name_prefixes
  db_connection_url_ssm_param_arn = var.db_connection_url_ssm_param_arn
  s3_load_bucket_name             = var.s3_load_bucket_name
  subnet_ids                      = var.subnet_ids
  vpc_id                          = var.vpc_id
}
