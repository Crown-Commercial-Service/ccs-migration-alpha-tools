locals {
  subnet_cidr_blocks = {
    "public" = {
      "a" = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 0),
      "b" = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1),
    }
    "web" = {
      "a" = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 2),
      "b" = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 3),
    }
    "application" = {
      "a" = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 4),
      "b" = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 5),
    }
    "database" = {
      "a" = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 6),
      "b" = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 7),
    }
  }
}
