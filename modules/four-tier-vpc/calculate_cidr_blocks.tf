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

  ipv6_subnet_cidr_blocks = {
    "application" = {
      "a" = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 4),
      "b" = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 5),
    }
    # "database" = {
    #   "a" = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 6),
    #   "b" = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 7),
    # }
    # "public" = {
    #   "a" = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 0),
    #   "b" = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 1),
    # }
    "web" = {
      "a" = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 2),
      "b" = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 3),
    }
  }
}
