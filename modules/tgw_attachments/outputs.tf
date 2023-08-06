output "transit_gateway_att_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.aws_ec2_transit_gateway_vpc_attachment[*].id
}
