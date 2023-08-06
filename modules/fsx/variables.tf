variable "account_name" {}

variable "fsx_user" {
  description = "FSx Admin Username"
}

variable "domain_name" {
  type = string
}

variable "storage_capacity" {}
variable "throughput_capacity" {}

variable "subnet_ids" {}
variable "dns_ips" {}

variable "deployment_type" {}
variable "storage_type" {}

variable "password" {
  sensitive = true
}

variable "ou" {}

variable "preferred_subnet_id" {}

# variable "security_groups" {}
