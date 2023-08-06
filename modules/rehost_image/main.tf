##### EC2 Migration Module ####
#####################

locals {
  formatted_hostname = lower(var.server.server_name)
}


data "aws_instance" "mgn_instance_ami" {
  filter {
    name   = "tag:Name"
    values = [var.read_amis_from_mgn_instance ? var.server.server_name : local.formatted_hostname]
  }
}

resource "aws_ami_from_instance" "migrated_ami_test" {
  count = var.read_amis_from_mgn_instance ? 1 : 0
  lifecycle {
    ignore_changes = []
  }
  name               = "${local.formatted_hostname}-MGN-${var.migration_status}"
  source_instance_id = data.aws_instance.mgn_instance_ami.id

  tags = {
    Name = "${local.formatted_hostname}-MGN-${var.migration_status}"
  }
}

resource "aws_ami_from_instance" "migrated_ami_cutover" {
  count = var.read_amis_from_mgn_instance ? 0 : 1
  lifecycle {
    ignore_changes = [source_instance_id, name]
  }
  name               = var.ami_name != null ? var.ami_name : local.formatted_hostname
  source_instance_id = data.aws_instance.mgn_instance_ami.id
}

# data "aws_security_group" "sg" {
#   id = var.app_sg_id
# }

locals {
  tags = {
    Name = local.formatted_hostname
    # environment         = var.server.environment
    # application         = var.server.application
    # pii                 = var.server.pii
    # dr-tier             = var.server.dr-tier
    # ams-managed         = var.server.ams-managed
    # it-owner-team       = var.server.it-owner-team
    # business-owner-team = var.server.business-owner-team
    # sub-business-owner  = var.server.sub-business-owner
    Backup = "True"
  }
}

resource "aws_instance" "servers" {

  instance_type          = var.server.instanceType
  ami                    = var.read_amis_from_mgn_instance ? aws_ami_from_instance.migrated_ami_test[0].id : aws_ami_from_instance.migrated_ami_cutover[0].id
  subnet_id              = var.server.subnet_IDs
  vpc_security_group_ids = [var.server.securitygroup_IDs]
  iam_instance_profile   = var.server.iamRole
  # volume_tags            = local.tags
  monitoring              = true
  private_ip              = var.server.private_ip
  disable_api_termination = var.api_protection

  tags = local.tags
}
