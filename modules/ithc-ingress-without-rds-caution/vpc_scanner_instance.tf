# Instance used to scan for vulnerabilities from inside the VPC.
#
resource "aws_key_pair" "vpc_scanner" {
  key_name   = "${var.resource_name_prefixes.hyphens_lower}-vpc-scanner"
  public_key = var.vpc_scanner_instance_public_key
}

data "aws_ami" "kali_pinned_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["kali-last-snapshot-amd64-2023.3.0-804fcc46-63fc-4eb6-85a1-50e66d6c7215"]
  }

  owners = [
    "aws-marketplace"
  ]
}

resource "aws_instance" "vpc_scanner" {
  associate_public_ip_address = true
  ami                         = data.aws_ami.kali_pinned_ami.id
  instance_type               = var.vpc_scanner_instance_type
  key_name                    = aws_key_pair.vpc_scanner.key_name
  subnet_id                   = var.vpc_scanner_instance_subnet_id
  vpc_security_group_ids      = [
    aws_security_group.vpc_scanner_instance.id,
  ]

  root_block_device {
    encrypted   = true
    volume_size = var.vpc_scanner_instance_root_device_size_gb
  }

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:EC2:VPCSCAN"
  }
}

resource "aws_security_group" "vpc_scanner_instance" {
  name        = "${var.resource_name_prefixes.normal}:EC2:VPCSCAN"
  description = "EC2 instance for VPC scanning"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:EC2:VPCSCAN"
  }
}

resource "aws_security_group_rule" "vpc_scanner_instance_ssh_in" {
  cidr_blocks       = var.ithc_operative_cidr_safelist
  description       = "Allow SSH from approved ranges into the VPC Scanner instance"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_scanner_instance.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "vpc_scanner_http_anywhere_out" {
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  description       = "Allows HTTP to anywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_scanner_instance.id
  type              = "egress"
}

resource "aws_security_group_rule" "vpc_scanner_https_anywhere_out" {
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  description       = "Allows HTTPS to anywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_scanner_instance.id
  type              = "egress"
}

resource "aws_security_group_rule" "vpc_scanner_all_tcp_vpc_out" {
  cidr_blocks = [
    var.vpc_cidr_block
  ]
  description       = "Any TCP within VPC"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_scanner_instance.id
  type              = "egress"
}

resource "aws_security_group_rule" "vpc_scanner_all_udp_vpc_out" {
  cidr_blocks = [
    var.vpc_cidr_block
  ]
  description       = "Any UDP within VPC"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  security_group_id = aws_security_group.vpc_scanner_instance.id
  type              = "egress"
}
