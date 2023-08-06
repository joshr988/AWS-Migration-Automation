variable "customer_name" {}

variable "bastion_name" {
  type    = string
  default = "bastion"
}

variable "linux_bastion" {
  type        = bool
  default     = true
  description = "Create a Liunux or Windows bastion. Default is Linux."
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "user_data" {
  type    = string
  default = <<EOF
  #!/bin/bash
  sudo dnf install python3
  cd /tmp
  sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  sudo yum install -y mysql
  sudo systemctl enable amazon-ssm-agent
  sudo systemctl start amazon-ssm-agent
  EOF
}

variable "create_sec_group" {
  default = true
  type    = bool
}

variable "security_group" {
  type    = string
  default = "aws_security_group.bastion_sg.id"
}

variable "set_ssh" {
  default = false
  type    = bool
}

variable "set_rdp" {
  default = false
  type    = bool
}

variable "set_egress" {
  default = true
  type    = bool
}

variable "ssh_port" {
  default = "22"
  type    = string
}

variable "rdp_port" {
  default = "3389"
  type    = string
}
