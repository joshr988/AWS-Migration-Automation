##### EC2 Module ####
#####################

locals {
  formatted_hostname = lower(var.server.server_name)
}

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

data "aws_subnet" "sub" {
  id = var.server.subnet_IDs
}

resource "aws_instance" "servers" {
  lifecycle {
    ignore_changes = [ami]
  }
  instance_type           = var.server.instanceType
  ami                     = data.aws_ami.onramp.id
  subnet_id               = var.server.subnet_IDs
  vpc_security_group_ids  = [var.server.securitygroup_IDs]
  iam_instance_profile    = var.server.iamRole
  monitoring              = true
  private_ip              = var.server.private_ip
  disable_api_termination = var.api_protection

  root_block_device {
    encrypted   = true
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = local.tags
}

resource "aws_ebs_volume" "additional" {
  for_each          = { for this_volume in var.volume_mappings : index(var.volume_mappings, this_volume) => this_volume }
  availability_zone = data.aws_subnet.sub.availability_zone
  size              = each.value.ebs_size
  type              = each.value.ebs_type
  encrypted         = true
  tags = {
    Name = "${local.formatted_hostname}-volume"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  for_each    = { for this_volume in var.volume_mappings : index(var.volume_mappings, this_volume) => this_volume }
  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.additional[each.key].id
  instance_id = aws_instance.servers.id
}
