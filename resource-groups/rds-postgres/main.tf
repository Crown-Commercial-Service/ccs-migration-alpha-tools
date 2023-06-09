resource "aws_db_subnet_group" "subnet_group" {
  name       = var.db_name
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "db" {
  allocated_storage               = var.allocated_storage_gb
  allow_major_version_upgrade     = false
  backup_retention_period         = var.backup_retention_period_days
  db_name                         = var.db_name # NB Postgres db names use underscores, not hyphens
  db_subnet_group_name            = aws_db_subnet_group.subnet_group.name
  enabled_cloudwatch_logs_exports = ["postgresql"]
  engine                          = "postgres"
  engine_version                  = var.postgres_engine_version
  identifier                      = var.db_name # NB RDS identifiers use hyphens, not underscores
  instance_class                  = var.db_instance_class
  multi_az                        = true
  password                        = random_password.db.result
  port                            = var.postgres_port
  publicly_accessible             = false
  skip_final_snapshot             = var.skip_final_snapshot
  storage_encrypted               = true
  username                        = var.db_username
  vpc_security_group_ids          = [aws_security_group.db.id]
}

resource "aws_security_group" "db" {
  name        = "${var.db_name}-db" # TODO rename
  description = "RDS ${var.db_name} DB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.db_name}-db"
  }
}

resource "aws_security_group" "db_clients" {
  name        = "${var.db_name}-db-clients" # TODO rename
  description = "Entities permitted to access the ${var.db_name} database"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.db_name}-db-clients"
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
