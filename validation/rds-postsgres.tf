module "rds_postgres" {
  source = "../resource-groups/rds-postgres"

  allocated_storage_gb         = 80
  backup_retention_period_days = 28
  db_instance_class            = "db.m1.medium"
  db_name                      = "db"
  db_username                  = "username"
  postgres_engine_version      = "14.8"
  postgres_port                = 8888
  resource_name_prefixes = {
    normal        = "CORE:DEMO"
    hyphens       = "CORE-DEMO"
    hyphens_lower = "core-demo"
  }
  skip_final_snapshot = false
  subnet_ids          = ["subnet-1234"]
  vpc_id              = "vpc-12345"
}
