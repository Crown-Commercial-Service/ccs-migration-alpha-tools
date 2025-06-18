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

output "private_subnets" {
  description = "Map of web & application subnets formatted for the EKS cluster"
  value = merge([
    for subnet in ["web", "application"] : {
      for az, subnet_id in local.subnet_attributes[subnet].az_ids :
      # build a unique key per subnet, e.g. "web-eu-west-2a"
      "${subnet}-${az}" => {
        id                = subnet_id
        cidr_block        = local.subnet_attributes[subnet].cidr_blocks[az]
        availability_zone = az
      }
    }
  ])
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}
