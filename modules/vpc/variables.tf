variable "aws_region" {
  default     = "us-east-1"
  description = "AWS Region"
}

variable "account_name" {
  type = string
}

variable "region_substring" {
  description = "AWS Region simple-format"
}

variable "azs" {
  type        = list(string)
  description = "List of AWS availability zones"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC Cidr Block"
}

variable "internet" {
  type        = string
  description = "Internet Route"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "List of Public subnet Cidr Block"
}

variable "application_subnet_cidr" {
  type        = list(string)
  description = "List of Application subnet Cidr Block"
}

variable "data_subnet_cidr" {
  type        = list(string)
  description = "List of Data subnet Cidr Block"
}

# variable "firewall_subnet_cidr" {
#   type        = list(string)
#   description = "List of Data subnet Cidr Block"
#   default     = ["100.64.0.0/28", "100.64.0.16/28", "100.64.0.32/28"]
# }

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags"
}

variable "global_region" {
  default     = "us-east-1"
  description = "Region for global resources"
}

variable "whitelist" {}

variable "create" {
  description = "Determines whether resources will be created"
  type        = bool
  default     = true
}

variable "endpoints" {
  description = "A map of interface and/or gateway endpoints containing their properties and configurations"
  type        = any
  default     = {}
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting VPC endpoint resources"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs variable"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security Group IDs"
  default     = []
}
