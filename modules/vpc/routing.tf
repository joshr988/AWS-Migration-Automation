# Routing Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-Public-RT"
    }
  )
}

resource "aws_route_table" "application_rt" {
  for_each = { for idx, az in var.azs : idx => az }
  vpc_id   = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-App-RT-${each.value}"
    }
  )
}

resource "aws_route_table" "data_rt" {
  for_each = { for idx, az in var.azs : idx => az }
  vpc_id   = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-Data-RT-${each.value}"
    }
  )
}

# NAT Routes

resource "aws_route" "application_nat_route" {
  for_each               = { for idx, az in var.azs : idx => az }
  route_table_id         = aws_route_table.application_rt[each.key].id
  destination_cidr_block = var.internet
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.key].id
  depends_on             = [aws_route_table.application_rt]
}

resource "aws_route" "data_nat_route" {
  for_each               = { for idx, az in var.azs : idx => az }
  route_table_id         = aws_route_table.data_rt[each.key].id
  destination_cidr_block = var.internet
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.key].id
  depends_on             = [aws_route_table.data_rt]
}

# Route table associations
resource "aws_route_table_association" "public_rta" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "application_rta" {
  for_each       = { for idx, subnet in aws_subnet.application_subnet : idx => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.application_rt[each.key].id
}

resource "aws_route_table_association" "data_rta" {
  for_each       = { for idx, subnet in aws_subnet.data_subnet : idx => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.data_rt[each.key].id
}
