variable "customer_name" {}

variable "environment" {}

variable "auto_accept_shared_attachments" {
  default = true
}
variable "default_route_table_association" {
  default = true
}
variable "default_route_table_propagation" {
  default = true
}
variable "dns_support" {
  default = true
}
variable "ipv6_support" {
  default = true
}

variable "tgw_att_id" {}

variable "region" {}

variable "ram_principals" {
  type = list(any)
}

variable "route_table_ids" {
  type = list(string)
}

variable "customer_gw_ip" {
  type = string
}

variable "customer_dc_networks" {
  type = list(string)
}

variable "bgp_asn" {
  type    = string
  default = "65000"
}
