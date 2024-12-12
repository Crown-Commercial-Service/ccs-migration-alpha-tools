resource "aws_subnet" "public" {
  for_each = local.subnet_cidr_blocks["public"]

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:SUBNET:PUBLIC:${each.key}"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route" "igw" {
  route_table_id         = aws_default_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "public" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-NAT-${each.key}"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_network_acl" "public_subnet" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PUBLIC"
  }
}

# We want cross-AZ redundancy so we define rules for both a and b subnets,
# as well as associating the ACL itself with both a and b subnets.
resource "aws_network_acl_association" "public_subnet" {
  for_each       = local.subnet_attributes.public.az_ids
  network_acl_id = aws_network_acl.public_subnet.id
  subnet_id      = each.value
}

# Rules for serving internet requests to LBs
#
resource "aws_network_acl_rule" "public__allow_https_everywhere_in" {
  cidr_block     = "0.0.0.0/0"
  egress         = false
  from_port      = 443
  network_acl_id = aws_network_acl.public_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5000
  to_port        = 443
}

resource "aws_network_acl_rule" "public__deny_25565_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 25565
  network_acl_id = aws_network_acl.public_subnet.id
  protocol       = "tcp"
  rule_action    = "deny"
  rule_number    = 5000
  to_port        = 25565
}

resource "aws_network_acl_rule" "public__allow_ephemeral_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 1024
  network_acl_id = aws_network_acl.public_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5100
  to_port        = 65535
}

# Rules for handling NAT requests
#
resource "aws_network_acl_rule" "public__allow_http_vpc_in" {
  cidr_block     = aws_vpc.vpc.cidr_block
  egress         = false
  from_port      = 80
  network_acl_id = aws_network_acl.public_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5100
  to_port        = 80
}

resource "aws_network_acl_rule" "public__allow_http_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 80
  network_acl_id = aws_network_acl.public_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5200
  to_port        = 80
}

# public__allow_https_vpc_in - already provided by allow_https_everywhere_in

resource "aws_network_acl_rule" "public__allow_https_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 443
  network_acl_id = aws_network_acl.public_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5300
  to_port        = 443
}

# Rules for handling responses to NAT requests
#
resource "aws_network_acl_rule" "public__allow_ephemeral_everywhere_in" {
  cidr_block     = "0.0.0.0/0"
  egress         = false
  from_port      = 1024
  network_acl_id = aws_network_acl.public_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5200
  to_port        = 65535
}

# public__allow_ephemeral_vpc_out - already provided by allow_ephemeral_everywhere_out

# Rules for LB Target Groups (traffic and healthchecks)
#
# public__allow_http_web_a_out, allow_http_web_b_out - already provided by allow_http_everywhere_out
# public__allow_ephemeral_web_a_in, allow_ephemeral_web_b_in - already provided by allow_ephemeral_everywhere_in
