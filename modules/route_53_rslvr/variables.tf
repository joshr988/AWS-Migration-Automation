variable "customer_name" {
  type = string
}

variable "route53_subnets" {
  type = list(string)
}

variable "customer_dns_ips" {
  type = list(string)
}


variable "customer_domain" {
  type = list(string)
}

# variable "customer_domain" {}

variable "whitelist" {
  default = ["10.0.0.0/8"]
}

variable "vpc_id" {}
