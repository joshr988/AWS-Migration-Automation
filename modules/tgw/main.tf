module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "= 2.6.0"

  name        = var.transit_gateway_name
  description = "TGW shared with several other AWS accounts"

  enable_auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  enable_default_route_table_association = var.default_route_table_association
  enable_default_route_table_propagation = var.default_route_table_propagation

  ram_allow_external_principals = true

  ram_principals = var.ram_principals

  tags = {
    Name = var.aws_transit_gateway_attachment_name
  }
}
