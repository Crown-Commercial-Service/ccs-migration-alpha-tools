resource "aws_security_group" "migrate_load_task" {
  name        = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:ECSTASK:LOAD"
  description = "Migrator Load task"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:ECSTASK:LOAD"
  }
}

resource "aws_security_group_rule" "migrate_load_task_https_out_anywhere" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow https out from load task to anywhere"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_load_task.id
  to_port           = 443
  type              = "egress"
}
