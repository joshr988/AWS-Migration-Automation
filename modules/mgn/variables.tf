variable "mgn_user" {}

variable "customer_name" {}

variable "whitelist" {}

variable "vpc_id" {}

variable "target_email" {
  description = "Email that will receive the notification"
}

variable "kms_region" {
  type = string
}

variable "test" {
  
}
