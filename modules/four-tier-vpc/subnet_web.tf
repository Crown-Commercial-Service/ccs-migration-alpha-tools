resource "aws_subnet" "web" {
  for_each = local.subnet_cidr_blocks["web"]

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name"                   = "${var.resource_name_prefixes.normal}:SUBNET:WEB:${each.key}"
    #"karpenter.sh/discovery" = "eks-${var.application_name}"
  }
}

resource "aws_route_table" "web" {
  for_each = aws_subnet.web

  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:RT:WEB:${each.key}"
  }
}

resource "aws_route_table_association" "web" {
  for_each       = aws_subnet.web
  route_table_id = aws_route_table.web[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route" "web_nat" {
  for_each = aws_route_table.web

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[each.key].id
}

resource "aws_network_acl" "web_subnet" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:WEB"
  }
}

# We want cross-AZ redundancy so we define rules for both a and b subnets,
# as well as associating the ACL itself with both a and b subnets.
resource "aws_network_acl_association" "web_subnet" {
  for_each       = local.subnet_attributes.web.az_ids
  network_acl_id = aws_network_acl.web_subnet.id
  subnet_id      = each.value
}

# Rules for servicing web service requests from LBs in public subnets
#
resource "aws_network_acl_rule" "web__allow_http_public_a_in" {
  cidr_block     = local.subnet_cidr_blocks.public.a
  egress         = false
  from_port      = 80
  network_acl_id = aws_network_acl.web_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5000
  to_port        = 80
}

resource "aws_network_acl_rule" "web__allow_http_public_b_in" {
  cidr_block     = local.subnet_cidr_blocks.public.b
  egress         = false
  from_port      = 80
  network_acl_id = aws_network_acl.web_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5100
  to_port        = 80
}

resource "aws_network_acl_rule" "web__deny_25565_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 25565
  network_acl_id = aws_network_acl.web_subnet.id
  protocol       = "tcp"
  rule_action    = "deny"
  rule_number    = 5000
  to_port        = 25565
}

resource "aws_network_acl_rule" "web__allow_ephemeral_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 1024
  network_acl_id = aws_network_acl.web_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5100
  to_port        = 65535
}

# Rules for instances to make outbound general requests (via NAT in public subnets)
#
resource "aws_network_acl_rule" "web__allow_http_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 80
  network_acl_id = aws_network_acl.web_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5300
  to_port        = 80
}

resource "aws_network_acl_rule" "web__allow_https_everywhere_out" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 443
  network_acl_id = aws_network_acl.web_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5400
  to_port        = 443
}

resource "aws_network_acl_rule" "web__allow_ephemeral_everywhere_in" {
  cidr_block     = "0.0.0.0/0"
  egress         = false
  from_port      = 1024
  network_acl_id = aws_network_acl.web_subnet.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5200
  to_port        = 65535
}

# Rules for instances to communicate with downstream LBs
#
# web__allow_http_application_a_out already provided by web__allow_http_everywhere_out
# web__allow_http_application_b_out already provided by web__allow_http_everywhere_out
# web__allow_ephemeral_application_a_in already provided by web__allow_ephemeral_everywhere_in
# web__allow_ephemeral_application_b_in already provided by web__allow_ephemeral_everywhere_in
