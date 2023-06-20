resource "aws_subnet" "public" {
  for_each = local.subnet_cidr_blocks["public"]

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:SUBNET:PUBLIC:${each.key}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-IGW"
  }
}

# TODO - Likely to need to do this differently from default table approach.
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route" "igw" {
  route_table_id         = aws_default_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "public" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-NAT-${each.key}"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}
