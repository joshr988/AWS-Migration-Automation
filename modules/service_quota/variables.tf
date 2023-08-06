variable "vcpu_increase_value" {
  type        = number
  description = "Maximum number of vCPUs assigned to the Running On-Demand Standard"
}

variable "ebs_storage_increase_value" {
  type        = number
  description = "The maximum aggregated amount of storage, in TiB, that can be provisioned across General Purpose SSD (gp3) volumes in this Region."
}

variable "lambda_concurrent_increase_value" {
  type        = number
  description = "The maximum number of events that functions can process simultaneously in the current Region"
}