module "postgres_etl" {
  source = "../modules/postgres-etl"

  db_clients_security_group_id = "sg-1234567890"
  ecs_cluster_arn              = "arn:aws:ecs:eu-west-2:123456789012:cluster/MAINAPP"
  ecs_execution_role = {
    arn  = "arn:aws:iam::123456789012:role/Project_Deployment"
    name = "Project_Deployment"
  }
  migrator_name                          = "migratoo000r"
  s3_bucket_name                         = "etl-bucket"
  source_db_connection_url_ssm_param_arn = "arn:aws:ssm:eu-west-2:123456789012:parameter/connection_url"
  vpc_id                                 = "vpc-1234"
}
