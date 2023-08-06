variable "auto_accept_shared_attachments" {}
variable "dns_support" {}
variable "ipv6_support" {}
variable "aws_transit_gateway_attachment_name" {}
variable "transit_gateway_name" {}
variable "default_route_table_association" {}
variable "default_route_table_propagation" {}

variable "environment" {}

variable "ram_principals" {
  type = list(any)
}

# variable "role_arn" {}


