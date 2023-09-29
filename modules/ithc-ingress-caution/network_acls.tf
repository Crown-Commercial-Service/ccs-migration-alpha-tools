# Override existing NACL - For rules on overriding see:
#   https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/tree/main/modules/four-tier-vpc#network-acls-and-customisation-of
#
resource "aws_network_acl_rule" "public__allow_ssh_everywhere_in" {
  for_each       = toset(var.ithc_operative_cidr_safelist)
  cidr_block     = each.value
  egress         = false
  from_port      = 22
  network_acl_id = var.public_subnets_nacl_id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = index(var.ithc_operative_cidr_safelist, each.value) + 1
  to_port        = 22
}

resource "aws_network_acl_rule" "public__allow_5432_database_a_out" {
  cidr_block     = var.database_subnet_cidr_blocks["a"]
  egress         = true
  from_port      = 5432
  network_acl_id = var.public_subnets_nacl_id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 1
  to_port        = 5432
}

resource "aws_network_acl_rule" "public__allow_5432_database_b_out" {
  cidr_block     = var.database_subnet_cidr_blocks["b"]
  egress         = true
  from_port      = 5432
  network_acl_id = var.public_subnets_nacl_id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 2
  to_port        = 5432
}

# There already exists a rule for public__allow_ephemeral_everywhere_in in the core implementation

resource "aws_network_acl_rule" "database__allow_5432_public_in" {
  cidr_block     = var.db_bastion_instance_subnet_cidr_block
  egress         = false
  from_port      = 5432
  network_acl_id = var.database_subnets_nacl_id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 1
  to_port        = 5432
}

resource "aws_network_acl_rule" "database__allow_ephemeral_public_out" {
  cidr_block     = var.db_bastion_instance_subnet_cidr_block
  egress         = true
  from_port      = 1024
  network_acl_id = var.database_subnets_nacl_id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 1
  to_port        = 65535
}
