resource "aws_subnet" "database" {
  for_each = local.subnet_cidr_blocks["database"]

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:SUBNET:DATABASE:${each.key}"
  }
}
