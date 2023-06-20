module "rds_postgres" {
  source = "../resource-groups/rds-postgres"

  db_name     = "db"
  db_username = "username"
  subnet_ids  = ["subnet-1234"]
  vpc_id      = "vpc-12345"
}
