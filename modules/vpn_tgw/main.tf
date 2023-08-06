### VPN/TGW Connection ###

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "= 2.6.0"

  name        = "tgw-shared-${var.region}"
  description = "TGW shared with several other AWS accounts"

  enable_auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  enable_default_route_table_association = var.default_route_table_association
  enable_default_route_table_propagation = var.default_route_table_propagation

  ram_allow_external_principals = true

  ram_principals = var.ram_principals

  tags = {
    Name = "tgw-shared-${var.region}"
  }
}

resource "aws_vpn_connection" "main" {
  depends_on = [
    module.tgw
  ]
  transit_gateway_id  = module.tgw.ec2_transit_gateway_id
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    "Name" = "${var.customer_name}-VPN"
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

resource "aws_ec2_transit_gateway_route" "vpn" {
  for_each                       = { for idx, subnet in var.customer_dc_networks : idx => subnet }
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = var.tgw_att_id
  transit_gateway_route_table_id = module.tgw.ec2_transit_gateway_association_default_route_table_id
}
