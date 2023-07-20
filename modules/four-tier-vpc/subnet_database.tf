resource "aws_subnet" "database" {
  for_each = local.subnet_cidr_blocks["database"]

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:SUBNET:DATABASE:${each.key}"
  }
}

resource "aws_network_acl" "database_subnet" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:DATABASE"
  }
}

# We want cross-AZ redundancy so we define rules for both a and b subnets,
# as well as associating the ACL itself with both a and b subnets.
resource "aws_network_acl_association" "database_subnet" {
  for_each       = local.subnet_attributes.database.az_ids
  network_acl_id = aws_network_acl.database_subnet.id
  subnet_id      = each.value
}

# Rules for servicing database requests from services in application subnets
#
resource "aws_network_acl_rule" "database__allow_application_a_in" {
  # Need to create a separate rule number for each database type (but use the db type as the instance key)
  for_each       = { for i, port_data in var.database_ports : port_data.db_type => { idx : i, port : port_data.port } }
  cidr_block     = local.subnet_cidr_blocks.application.a
  egress         = false
  from_port      = each.value.port
  network_acl_id = aws_network_acl.database_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5000 + each.value.idx
  to_port        = each.value.port
}

resource "aws_network_acl_rule" "database__allow_application_b_in" {
  # Need to create a separate rule number for each database type (but use the db type as the instance key)
  for_each       = { for i, port_data in var.database_ports : port_data.db_type => { idx : i, port : port_data.port } }
  cidr_block     = local.subnet_cidr_blocks.application.b
  egress         = false
  from_port      = each.value.port
  network_acl_id = aws_network_acl.database_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5100 + each.value.idx
  to_port        = each.value.port
}

resource "aws_network_acl_rule" "database__deny_25565_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 25565
  network_acl_id = aws_network_acl.database_subnet.id
  protocol       = "tcp"
  rule_action    = "deny"
  rule_number    = 5000
  to_port        = 25565
}

resource "aws_network_acl_rule" "database__allow_ephemeral_application_a_out" {
  cidr_block     = local.subnet_cidr_blocks.application.a
  egress         = true
  from_port      = 1024
  network_acl_id = aws_network_acl.database_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5100
  to_port        = 65535
}

resource "aws_network_acl_rule" "database__allow_ephemeral_application_b_out" {
  cidr_block     = local.subnet_cidr_blocks.application.b
  egress         = true
  from_port      = 1024
  network_acl_id = aws_network_acl.database_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5200
  to_port        = 65535
}
