resource "aws_security_group" "etl_extract_task" {
  name        = "${var.resource_name_prefixes.normal}:${upper(var.migrator_name)}:ECSTASK:EXTRACT"
  description = "PG ETL Extract task"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:${upper(var.migrator_name)}:ECSTASK:EXTRACT"
  }
}

resource "aws_security_group_rule" "etl_extract_task_https_out_anywhere" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow https out from extract task to anywhere"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.etl_extract_task.id
  to_port           = 443
  type              = "egress"
}

data "aws_security_group" "etl_extract_task" {
  name = aws_security_group.etl_extract_task.id
}
