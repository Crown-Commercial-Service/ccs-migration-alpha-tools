output "nat_eip_cidr_blocks" {
  description = "List containing /32 CIDRs blocks representing the address for each NAT gateway's elastic IP address"
  value       = [for eip in aws_eip.nat : "${eip.public_ip}/32"]
}

output "network_acl_ids" {
  description = "The IDs of the Network ACLs for each subnet"
  value = {
    application = aws_network_acl.application_subnet.id
    database    = aws_network_acl.database_subnet.id
    public      = aws_network_acl.public_subnet.id
    web         = aws_network_acl.web_subnet.id
  }
}

output "subnets" {
  description = "Properties relating to the four subnets"
  value       = local.subnet_attributes
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}
