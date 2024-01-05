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
