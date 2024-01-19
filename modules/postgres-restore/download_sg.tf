resource "aws_security_group" "migrate_download_task" {
  name        = "${var.resource_name_prefixes.normal}:PGRESTORE:${upper(var.restore_name)}:ECSTASK:DOWNLOAD"
  description = "Restore Download task"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PGRESTORE:${upper(var.restore_name)}:ECSTASK:DOWNLOAD"
  }
}

resource "aws_security_group_rule" "migrate_download_task_https_out_anywhere" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow https out from download task to anywhere"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_download_task.id
  to_port           = 443
  type              = "egress"
}

