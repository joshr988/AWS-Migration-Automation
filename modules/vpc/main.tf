# locals {
#   iam_region = var.aws_region == var.global_region
# }

data "aws_caller_identity" "current" {}

# VPC
resource "aws_vpc" "vpc" {
  enable_dns_hostnames = true
  cidr_block           = var.vpc_cidr
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.env}-${var.region_substring}"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-IGW"
    }
  )
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  for_each      = { for idx, az in var.azs : idx => az }
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-NATGW-${each.value}"
    }
  )
}

#Elastic IPs for NAT Gateways 
resource "aws_eip" "nat_eip" {
  for_each = { for idx, az in var.azs : idx => az }
  vpc      = true
  # TODO assign specific ips/ network interfaces if required

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-NAT-EIP-${each.value}"
    }
  )
}
