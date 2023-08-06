variable "server" {
  type = map(any)
}

variable "migration_status" {
  default = "Test"
}

# variable "app_sg_id" {
#   type = string
# }

variable "read_amis_from_mgn_instance" {
  default = true
}

# variable "iam_instance_profile" {}

variable "api_protection" {
  type = bool
}

variable "ami_name" {
  description = "Use to override lld csv"
  default     = null
}
