resource "aws_db_subnet_group" "subnet_group" {
  name       = var.db_name
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "db" {
  allocated_storage                   = var.allocated_storage_gb
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  apply_immediately                   = var.apply_immediately
  backup_retention_period             = var.backup_retention_period_days
  ca_cert_identifier                  = var.ca_cert_identifier
  db_name                             = var.db_name # NB Postgres db names use underscores, not hyphens
  db_subnet_group_name                = aws_db_subnet_group.subnet_group.name
  deletion_protection                 = var.deletion_protection
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  engine                              = "postgres"
  engine_version                      = var.postgres_engine_version
  final_snapshot_identifier           = var.skip_final_snapshot ? null : var.final_snapshot_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  identifier                          = var.db_name # NB RDS identifiers use hyphens, not underscores
  instance_class                      = var.db_instance_class
  iops                                = var.storage_iops
  monitoring_interval                 = var.monitoring_interval
  monitoring_role_arn                 = var.monitoring_role_arn
  multi_az                            = true
  password                            = random_password.db.result
  parameter_group_name                = var.parameter_group_name
  performance_insights_enabled        = var.performance_insights_enabled
  port                                = var.postgres_port
  publicly_accessible                 = false
  skip_final_snapshot                 = var.skip_final_snapshot
  storage_encrypted                   = true
  storage_throughput                  = var.storage_throughput
  storage_type                        = var.storage_type
  username                            = var.db_username
  vpc_security_group_ids              = [aws_security_group.db.id]
}

resource "aws_security_group" "db" {
  name        = "${var.resource_name_prefixes.normal}:DB:${upper(var.db_name)}"
  description = "RDS ${var.db_name} DB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:DB:${upper(var.db_name)}"
  }
}

resource "aws_security_group" "db_clients" {
  name        = "${var.resource_name_prefixes.normal}:DBCLIENTS:${upper(var.db_name)}"
  description = "Entities permitted to access the ${var.db_name} database"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:DBCLIENTS:${upper(var.db_name)}"
  }
}

resource "aws_security_group_rule" "db_postgres_in" {
  security_group_id = aws_security_group.db.id
  description       = "Allow ${var.postgres_port} inwards from db-clients SG"

  from_port                = var.postgres_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db_clients.id
  to_port                  = var.postgres_port
  type                     = "ingress"
}

resource "aws_security_group_rule" "db_client_postgres_out" {
  security_group_id = aws_security_group.db_clients.id
  description       = "Allow ${var.postgres_port} from to db"

  from_port                = var.postgres_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id
  to_port                  = var.postgres_port
  type                     = "egress"
}
