resource "aws_vpc" "vpc" {
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = var.vpc_cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = {
    Name = "${var.resource_name_prefixes.normal}:VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-IGW"
  }
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-EIGW"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-RT"
  }
}

resource "aws_route" "ipv6_egress" {
  route_table_id            = aws_route_table.rt.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id    = aws_egress_only_internet_gateway.eigw.id
}

resource "aws_security_group" "ipv6_egress" {
  name        = "${var.resource_name_prefixes.normal}:SG:IPV6_EGRESS"
  description = "Allow all outbound IPv6 traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:SG:IPV6_EGRESS"
  }
}

resource "aws_security_group_rule" "ipv6_egress" {
  security_group_id = aws_security_group.ipv6_egress.id
  from_port         = 0
  to_port           = 0
  protocol          = "HTTPS"
  cidr_blocks       = ["::/0"]
  ipv6_cidr_blocks  = ["::/0"]
  type              = "egress"
}

resource "aws_network_acl" "ipv6_egress" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:NA:IPV6_EGRESS"
  }
}

resource "aws_network_acl_rule" "ipv6_egress" {
  network_acl_id = aws_network_acl.ipv6_egress.id
  rule_number    = 6000
  egress         = true
  protocol       = "HTTPS"
  rule_action    = "allow"
  cidr_block     = "::/0"
  ipv6_cidr_block = "::/0"
  from_port      = 443
  to_port        = 443
}
