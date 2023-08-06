resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    "Name" = "${var.customer_name}-VPN"
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = var.vpc_id

  tags = {
    "Name" = "${var.customer_name}-VPN-GW"
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = var.bgp_asn
  ip_address = var.customer_gw_ip
  type       = "ipsec.1"

  tags = {
    "Name" = "${var.customer_name}-CGW"
  }
}

resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  vpc_id         = var.vpc_id
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
}

resource "aws_vpn_connection_route" "customer_network" {
  for_each               = { for idx, subnet in var.customer_dc_networks : idx => subnet }
  destination_cidr_block = each.value
  vpn_connection_id      = aws_vpn_connection.main.id
}

resource "aws_vpn_gateway_route_propagation" "vpn_route_propagation" {
  for_each       = toset(var.route_table_ids)
  route_table_id = each.key
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
}
