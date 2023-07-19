output "subnets" {
  description = "Properties relating to the four subnets"
  value = {
    "public" = {
      "az_ids" : { for suffix, _ in local.subnet_cidr_blocks.public : suffix => aws_subnet.public[suffix].id }
      "ids" : [for s in aws_subnet.public : s.id]
    },
    "web" = {
      "az_ids" : { for suffix, _ in local.subnet_cidr_blocks.web : suffix => aws_subnet.web[suffix].id }
      "ids" : [for s in aws_subnet.web : s.id]
    },
    "application" = {
      "az_ids" : { for suffix, _ in local.subnet_cidr_blocks.application : suffix => aws_subnet.application[suffix].id }
      "ids" : [for s in aws_subnet.application : s.id]
    },
    "database" = {
      "az_ids" : { for suffix, _ in local.subnet_cidr_blocks.database : suffix => aws_subnet.database[suffix].id }
      "ids" : [for s in aws_subnet.database : s.id]
    }
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}
