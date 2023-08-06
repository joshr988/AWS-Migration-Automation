
output "ec2_transit_gateway_identifier_id" {
  value = module.tgw.ec2_transit_gateway_id
}

output "resource_share_arn" {
  value = module.tgw.ram_resource_share_id
}

output "ec2_transit_gateway_rtb_id" {
  value = module.tgw.ec2_transit_gateway_association_default_route_table_id
}
