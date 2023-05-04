output "default_route_table_id" {
  description = "ID of the default route table for the primary VPC"
  value       = data.aws_vpc.primary.main_route_table_id
}

output "primary_vpc_id" {
  description = "ID of the primary VPC as implemented by the TechOps control process."
  value       = data.aws_vpc.primary.id
}

/* While not mandatory, there is a *recommended* subnet structure and so it is helpful to
   provide tools which do the network math for devops engineers automatically.

   Adopting the outputs below will give you subnet CIDRs compliant with the suggested
   structure, namely:

   +=============================================+
   | Subnet Type | AZ a          | AZ b          |
   +---------------------------------------------+
   | public      | 10.x.y.0/27   | 10.x.y.32/27  |
   | web         | 10.x.y.64/27  | 10.x.y.96/27  |
   | application | 10.x.y.128/27 | 10.x.y.160/27 |
   | database    | 10.x.y.192/27 | 10.x.y.224/27 |
   +=============================================+

   This is predicated on the notion that the CIDR block for the VPC itself has a 24-bit
   mask, e.g. 10.x.y.0/24.

   Note also that the use of AZ suffixes "a" and "b" does not favour specific
   physical AWS AZs because AWS themselves randomise the actual AZs addressed
   by these suffixes - see: https://docs.aws.amazon.com/ram/latest/userguide/working-with-az-ids.html
*/

output "recommended_subnet_cidrs" {
  description = "Map of suggested CIDR blocks for common subnet use cases"
  value       = {
    "public" = {
      "a" = cidrsubnet(data.aws_vpc.primary.cidr_block, 3, 0),
      "b" = cidrsubnet(data.aws_vpc.primary.cidr_block, 3, 1),
    }
    "web" = {
      "a" = cidrsubnet(data.aws_vpc.primary.cidr_block, 3, 2),
      "b" = cidrsubnet(data.aws_vpc.primary.cidr_block, 3, 3),
    }
    "application" = {
      "a" = cidrsubnet(data.aws_vpc.primary.cidr_block, 3, 4),
      "b" = cidrsubnet(data.aws_vpc.primary.cidr_block, 3, 5),
    }
    "database" = {
      "a" = cidrsubnet(data.aws_vpc.primary.cidr_block, 3, 6),
      "b" = cidrsubnet(data.aws_vpc.primary.cidr_block, 3, 7),
    }
  }
}
