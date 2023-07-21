module "rds_postgres" {
  source = "../resource-groups/rds-postgres"

  allocated_storage_gb         = 80
  backup_retention_period_days = 28
  db_instance_class            = "db.m1.medium"
  db_name                      = "db"
  db_username                  = "username"
  postgres_engine_version      = "14.7"
  postgres_port                = 8888
  skip_final_snapshot          = false
  subnet_ids                   = ["subnet-1234"]
  vpc_id                       = "vpc-12345"
}
