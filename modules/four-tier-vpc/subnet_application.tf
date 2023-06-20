resource "aws_subnet" "application" {
  for_each = local.subnet_cidr_blocks["application"]

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:SUBNET:APPLICATION:${each.key}"
  }
}

resource "aws_route_table" "application" {
  for_each = aws_subnet.application

  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:RT:APPLICATION:${each.key}"
  }
}

resource "aws_route_table_association" "application" {
  for_each       = aws_subnet.application
  route_table_id = aws_route_table.application[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route" "application_nat" {
  for_each = aws_route_table.application

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[each.key].id
}
