resource "aws_security_group" "migrate_extract_task" {
  name        = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:ECSTASK:EXTRACT"
  description = "Migrator Extract task"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:ECSTASK:EXTRACT"
  }
}

resource "aws_security_group_rule" "migrate_extract_task_https_out_anywhere" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow https out from extract task to anywhere"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_extract_task.id
  to_port           = 443
  type              = "egress"
}

resource "aws_security_group_rule" "migrate_extract_task_ssh_ish_out_anywhere" {
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allows outbound ssh_ish anywhere (bespoke requirement for cf conduit)"
  # See https://github.com/alphagov/paas-cf-conduit/pull/65
  from_port         = 2222
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_extract_task.id
  to_port           = 2222
  type              = "egress"
}

data "aws_security_group" "migrate_extract_task" {
  name = aws_security_group.migrate_extract_task.id
}
