output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_name" {
  value = lookup(aws_vpc.vpc.tags, "Name")
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "whitelist" {
  value = var.whitelist
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "application_route_table_ids" {
  value = values(aws_route_table.application_rt)[*].id
}

output "data_route_table_ids" {
  value = values(aws_route_table.data_rt)[*].id
}

output "public_subnet_ids" {
  value = values(aws_subnet.public_subnet)[*].id
}

output "application_subnet_ids" {
  value = values(aws_subnet.application_subnet)[*].id
}

output "data_subnet_ids" {
  value = values(aws_subnet.data_subnet)[*].id
}

output "ssh_sg" {
  value = aws_security_group.ssh_admin.id
}

output "rdp_sg" {
  value = aws_security_group.rdp_admin.id
}

output "endpoint_sg" {
  value = aws_security_group.endpoint.id
}

output "all_vpc_endpoints" {
  value = values(aws_vpc_endpoint.all)[*].id
}
