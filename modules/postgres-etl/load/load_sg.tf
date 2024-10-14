resource "aws_security_group" "etl_load_task" {
  name        = "${var.resource_name_prefixes.normal}:PG:${upper(var.migrator_name)}:ECSTASK:LOAD"
  description = "PG ETL Load task"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PG:${upper(var.migrator_name)}:ECSTASK:LOAD"
  }
}

resource "aws_security_group_rule" "etl_load_task_https_out_anywhere" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow https out from load task to anywhere"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.etl_load_task.id
  to_port           = 443
  type              = "egress"
}
