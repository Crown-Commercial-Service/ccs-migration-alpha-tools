# Instance used to route Postgres connections via SSH tunnel
#
resource "aws_key_pair" "db_bastion" {
  key_name   = "${var.resource_name_prefixes.hyphens_lower}-db-bastion"
  public_key = var.db_bastion_instance_public_key
}

data "aws_ami" "amazon_linux_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = [
    "amazon"
  ]
}

resource "aws_instance" "db_bastion" {
  associate_public_ip_address = true
  ami                         = data.aws_ami.amazon_linux_ami.id
  instance_type               = var.db_bastion_instance_type
  key_name                    = aws_key_pair.db_bastion.key_name
  subnet_id                   = var.db_bastion_instance_subnet_id
  vpc_security_group_ids      = concat(
    [aws_security_group.db_bastion_instance.id],
    # Note that the db_clients_security_group already provides SG rules for connecting
    var.db_clients_security_group_ids,
  )

  root_block_device {
    encrypted   = true
    volume_size = var.db_bastion_instance_root_device_size_gb
  }

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:EC2:DBBASTION"
  }
}

resource "aws_security_group" "db_bastion_instance" {
  name        = "${var.resource_name_prefixes.normal}:EC2:DBBASTION"
  description = "EC2 instance for DB bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:EC2:DBBASTION"
  }
}

resource "aws_security_group_rule" "db_bastion_instance_ssh_in" {
  cidr_blocks       = var.ithc_operative_cidr_safelist
  description       = "Allow SSH from approved ranges into the DB Bastion instance"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.db_bastion_instance.id
  to_port           = 22
  type              = "ingress"
}
