resource "aws_subnet" "application" {
  for_each = local.subnet_cidr_blocks["application"]

  assign_ipv6_address_on_creation = true
  availability_zone               = "${var.aws_region}${each.key}"
  cidr_block                      = each.value
  ipv6_cidr_block                 = local.ipv6_subnet_cidr_blocks["application"][each.key]
  vpc_id                          = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:SUBNET:APPLICATION:${each.key}"
  }
}

resource "aws_route_table" "application" {
  for_each = aws_subnet.application

  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:RT:APPLICATION:${each.key}"
  }
}

resource "aws_route_table_association" "application" {
  for_each       = aws_subnet.application
  route_table_id = aws_route_table.application[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route" "application_nat" {
  for_each = aws_route_table.application

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[each.key].id
}

resource "aws_network_acl" "application_subnet" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:APPLICATION"
  }
}

# We want cross-AZ redundancy so we define rules for both a and b subnets,
# as well as associating the ACL itself with both a and b subnets.
resource "aws_network_acl_association" "application_subnet" {
  for_each       = local.subnet_attributes.application.az_ids
  network_acl_id = aws_network_acl.application_subnet.id
  subnet_id      = each.value
}

# Rules for inbound traffic from the web subnets
#
resource "aws_network_acl_rule" "application__allow_http_web_a_in" {
  cidr_block      = local.subnet_cidr_blocks.web.a
  egress          = false
  from_port       = 80
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5000
  to_port         = 80
}

resource "aws_network_acl_rule" "application__allow_ipv6_http_web_a_in" {
  egress          = false
  from_port       = 80
  ipv6_cidr_block = local.ipv6_subnet_cidr_blocks.web.a
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5501
  to_port         = 80
}

resource "aws_network_acl_rule" "application__allow_http_web_b_in" {
  cidr_block      = local.subnet_cidr_blocks.web.b
  egress          = false
  from_port       = 80
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5001
  to_port         = 80
}

resource "aws_network_acl_rule" "application__allow_ipv6_http_web_b_in" {
  egress          = false
  from_port       = 80
  ipv6_cidr_block = local.ipv6_subnet_cidr_blocks.web.b
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5502
  to_port         = 80
}

# Rules for inbound traffic from the application subnets (think cross-AZ)
#
resource "aws_network_acl_rule" "application__allow_http_application_a_in" {
  cidr_block      = local.subnet_cidr_blocks.application.a
  egress          = false
  from_port       = 80
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5002
  to_port         = 80
}

resource "aws_network_acl_rule" "application__allow_ipv6_http_application_a_in" {
  egress          = false
  from_port       = 80
  ipv6_cidr_block = local.ipv6_subnet_cidr_blocks.application.a
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5503
  to_port         = 80
}

resource "aws_network_acl_rule" "application__allow_http_application_b_in" {
  cidr_block      = local.subnet_cidr_blocks.application.b
  egress          = false
  from_port       = 80
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5003
  to_port         = 80
}

resource "aws_network_acl_rule" "application__allow_ipv6_http_application_b_in" {
  egress          = false
  from_port       = 80
  ipv6_cidr_block = local.ipv6_subnet_cidr_blocks.application.b
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5505
  to_port         = 80
}

resource "aws_network_acl_rule" "application__deny_25565_everywhere_out" {
  cidr_block      = "0.0.0.0/0"
  egress          = true
  from_port       = 25565
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "deny"
  rule_number     = 5000
  to_port         = 25565
}

resource "aws_network_acl_rule" "application__allow_ephemeral_everywhere_out" {
  cidr_block      = "0.0.0.0/0"
  egress          = true
  from_port       = 1024
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5100
  to_port         = 65535
}

resource "aws_network_acl_rule" "application__allow_ipv6_ephemeral_everywhere_out" {
  egress          = true
  from_port       = 1024
  ipv6_cidr_block = "::/0"
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5800
  to_port         = 65535
}

# Rules for instances to make outbound general requests (via NAT in web subnets)
#
resource "aws_network_acl_rule" "application__allow_http_everywhere_out" {
  cidr_block      = "0.0.0.0/0"
  egress          = true
  from_port       = 80
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5300
  to_port         = 80
}

resource "aws_network_acl_rule" "application__allow_ipv6_8080_everywhere_out" {
  egress          = true
  from_port       = 8080
  ipv6_cidr_block = "::/0"
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5700
  to_port         = 8080
}

resource "aws_network_acl_rule" "application__allow_https_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 443
  network_acl_id = aws_network_acl.application_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5400
  to_port        = 443
}

resource "aws_network_acl_rule" "application__allow_ipv6_8888_everywhere_in" {
  egress          = true
  from_port       = 8888
  ipv6_cidr_block = "::/0"
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5300
  to_port         = 8888
}

resource "aws_network_acl_rule" "application__allow_ephemeral_everywhere_in" {
  cidr_block      = "0.0.0.0/0"
  egress          = false
  from_port       = 1024
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5200
  to_port         = 65535
}

resource "aws_network_acl_rule" "application__allow_ipv6_ephemeral_everywhere_in" {
  egress          = false
  from_port       = 1024
  ipv6_cidr_block = "::/0"
  network_acl_id  = aws_network_acl.application_subnet.id
  protocol        = "tcp"
  rule_action     = "allow"
  rule_number     = 5400
  to_port         = 65535
}

# Rules for instances to communicate with downstream DBs
#
resource "aws_network_acl_rule" "application__allow_database_a_out" {
  # Need to create a separate rule number for each database type (but use the db type as the instance key)
  for_each       = { for i, port_data in var.database_ports : port_data.db_type => { idx : i, port : port_data.port } }
  cidr_block     = local.subnet_cidr_blocks.database.a
  egress         = true
  from_port      = each.value.port
  network_acl_id = aws_network_acl.application_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5500 + each.value.idx
  to_port        = each.value.port
}

resource "aws_network_acl_rule" "application__allow_database_b_out" {
  # Need to create a separate rule number for each database type (but use the db type as the instance key)
  for_each       = { for i, port_data in var.database_ports : port_data.db_type => { idx : i, port : port_data.port } }
  cidr_block     = local.subnet_cidr_blocks.database.b
  egress         = true
  from_port      = each.value.port
  network_acl_id = aws_network_acl.application_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5600 + each.value.idx
  to_port        = each.value.port
}

# application__allow_ephemeral_database_a_in already provided by application__allow_ephemeral_everywhere_in
# application__allow_ephemeral_database_b_in already provided by application__allow_ephemeral_everywhere_in
