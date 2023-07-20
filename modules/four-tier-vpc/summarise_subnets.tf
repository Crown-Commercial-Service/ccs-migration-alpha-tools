locals {
  subnet_attributes = {
    "public" = {
      "az_ids" : { for suffix, _ in local.subnet_cidr_blocks.public : suffix => aws_subnet.public[suffix].id },
      "cidr_blocks" : local.subnet_cidr_blocks.public,
      "ids" : [for s in aws_subnet.public : s.id]
    },
    "web" = {
      "az_ids" : { for suffix, _ in local.subnet_cidr_blocks.web : suffix => aws_subnet.web[suffix].id },
      "cidr_blocks" : local.subnet_cidr_blocks.web,
      "ids" : [for s in aws_subnet.web : s.id]
    },
    "application" = {
      "az_ids" : { for suffix, _ in local.subnet_cidr_blocks.application : suffix => aws_subnet.application[suffix].id },
      "cidr_blocks" : local.subnet_cidr_blocks.application,
      "ids" : [for s in aws_subnet.application : s.id]
    },
    "database" = {
      "az_ids" : { for suffix, _ in local.subnet_cidr_blocks.database : suffix => aws_subnet.database[suffix].id },
      "cidr_blocks" : local.subnet_cidr_blocks.database,
      "ids" : [for s in aws_subnet.database : s.id]
    }
  }
}
