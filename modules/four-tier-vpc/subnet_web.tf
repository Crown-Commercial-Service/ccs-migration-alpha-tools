resource "aws_subnet" "web" {
  for_each = local.subnet_cidr_blocks["web"]

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:SUBNET:WEB:${each.key}"
  }
}

resource "aws_route_table" "web" {
  for_each = aws_subnet.web

  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:RT:WEB:${each.key}"
  }
}

resource "aws_route_table_association" "web" {
  for_each       = aws_subnet.web
  route_table_id = aws_route_table.web[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route" "web_nat" {
  for_each = aws_route_table.web

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[each.key].id
}
