variable "customer_name" {}

variable "vpc_id" {
  type = string
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
