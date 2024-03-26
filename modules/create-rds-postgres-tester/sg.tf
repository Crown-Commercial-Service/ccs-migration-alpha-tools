resource "aws_security_group" "create_rds_postgres_tester" {
  name        = "${var.resource_name_prefixes.normal}:RDSPOSTGRES:${upper(var.migrator_name)}:ECSTASK:TESTER"
  description = "Create RDS Postgres Tester task"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:RDSPOSTGRES:${upper(var.migrator_name)}:ECSTASK:TESTER"
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
