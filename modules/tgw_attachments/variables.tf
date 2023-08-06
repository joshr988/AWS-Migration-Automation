variable "transit_gateway_id" {}

variable "subnet_ids" {
  type = list(any)
}

variable "vpc_id" {}


variable "name" {
  type = string
}

variable "app_route_table_ids" {
  type = list(string)
}

variable "data_route_table_ids" {
  type = list(string)
}
