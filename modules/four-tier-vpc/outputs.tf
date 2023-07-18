output "network_acl_ids" {
  description = "The IDs of the Network ACLs for each subnet"
  value = {
    public = aws_network_acl.public_subnet.id
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
