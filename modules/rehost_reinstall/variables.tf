variable "server" {
  type = map(any)
}

variable "windows_ami" {
  default = true
}

# variable "iam_instance_profile" {}

variable "api_protection" {
  type    = bool
  default = true
}

variable "volume_mappings" {
  type = list(object({ device_name = string, ebs_size = string, ebs_type = string }))
}

variable "root_volume_size" {
  type    = string
  default = "100"
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "ami_name" {}
