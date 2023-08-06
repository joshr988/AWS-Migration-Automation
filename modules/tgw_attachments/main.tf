
resource "aws_ec2_transit_gateway_vpc_attachment" "aws_ec2_transit_gateway_vpc_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id

  tags = {
    Name = var.name
  }
}

# TGW ROUTES
# ````````````````````````
resource "aws_route" "application_tgw_route" {
  for_each               = toset(var.app_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "application_tgw_route2" {
  for_each               = toset(var.app_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gateway_id
}

# ````````````````````````
resource "aws_route" "data_tgw_route" {
  for_each               = toset(var.data_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "data_tgw_route2" {
  for_each               = toset(var.data_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gateway_id
}

# ````````````````````````
