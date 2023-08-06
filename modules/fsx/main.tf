## FSx Windows File System

resource "aws_fsx_windows_file_system" "fsx" {
  storage_capacity    = var.storage_capacity
  subnet_ids          = var.subnet_ids
  throughput_capacity = var.throughput_capacity
  deployment_type     = var.deployment_type
  storage_type        = var.storage_type
  preferred_subnet_id = var.preferred_subnet_id
  # security_group_ids  = var.security_groups

  self_managed_active_directory {
    dns_ips                                = var.dns_ips
    domain_name                            = var.domain_name
    password                               = var.password
    username                               = var.fsx_user
    organizational_unit_distinguished_name = var.ou
  }

  tags = {
    Name = "${var.account_name}-Fsx"
  }
}

## AD Admin User Credentials ##

# resource "random_password" "fsx_password" {
#   length      = 18
#   min_numeric = 1
#   min_special = 1
#   min_upper   = 1
#   special     = true
# }

# resource "aws_ssm_parameter" "fsx_password" {
#   name        = "/${var.account_name}/fsx_password"
#   description = "FSx Share password"
#   type        = "SecureString"
#   value       = random_password.oracle_password.result
#   overwrite   = true
# }
