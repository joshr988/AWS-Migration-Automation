# Subnets
resource "aws_subnet" "public_subnet" {
  for_each          = { for idx, az in var.azs : idx => az }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr[each.key]
  availability_zone = each.value

  tags = merge(
    var.tags,
    {
      "Name" = "${var.account_name}-${var.env}-Public-${each.value}"
    }
  )
}

resource "aws_subnet" "application_subnet" {
  for_each          = { for idx, az in var.azs : idx => az }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.application_subnet_cidr[each.key]
  availability_zone = each.value

  tags = merge(
    var.tags,
    {
      "Name" = "${var.account_name}-${var.env}-App-${each.value}"
    }
  )
}

resource "aws_subnet" "data_subnet" {
  for_each          = { for idx, az in var.azs : idx => az }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.data_subnet_cidr[each.key]
  availability_zone = each.value

  tags = merge(
    var.tags,
    {
      "Name" = "${var.account_name}-${var.env}-Data-${each.value}"
    }
  )
}

# resource "aws_subnet" "net_firewall_subnet" {
#   for_each          = { for idx, az in var.azs : idx => az }
#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = var.firewall_subnet_cidr[each.key]
#   availability_zone = each.value

#   tags = merge(
#     var.tags,
#     {
#       "Name" = "${var.account_name}-${var.env}-Firewall-${each.value}"
#     }
#   )
# }
