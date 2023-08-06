## AD Servers ##

resource "aws_instance" "ad_servers" {
  lifecycle {
    ignore_changes = [iam_instance_profile, ami]
  }
  count                   = 2
  ami                     = data.aws_ami.win2019.id
  instance_type           = "t3.medium"
  subnet_id               = element(var.data_subnet_2ab_id, count.index)
  vpc_security_group_ids  = [aws_security_group.ad.id]
  iam_instance_profile    = "SSM_Profile"
  key_name                = "ADkey"
  private_ip              = element(var.ad_ips, count.index)
  disable_api_termination = true

  tags = {
    Name   = "AD-Server-${count.index + 1}"
    Backup = "True"
  }
}


# Creates a security group for AD tier

resource "aws_security_group" "ad" {
  name        = "${var.environment}-${var.app_name}-AD-SG"
  description = "Access to AD"
  vpc_id      = data.terraform_remote_state.lz_state.outputs.vpc_id

  tags = {
    "Name" : "${var.environment}-${var.app_name}-AD-SG",
    "Environment" : var.environment,
    "Application" : var.app_name,
    "AppRole" : "AD"
  }
}

resource "aws_security_group_rule" "ad_53_rule" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_88_rule" {
  type              = "ingress"
  from_port         = 88
  to_port           = 88
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_ntp_rule" {
  type              = "ingress"
  from_port         = 123
  to_port           = 123
  protocol          = "UDP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_88udp_rule" {
  type              = "ingress"
  from_port         = 88
  to_port           = 88
  protocol          = "UDP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_389_rule" {
  type              = "ingress"
  from_port         = 389
  to_port           = 389
  protocol          = "UDP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_464udp_rule" {
  type              = "ingress"
  from_port         = 464
  to_port           = 464
  protocol          = "UDP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}


resource "aws_security_group_rule" "ad_rpc_rule" {
  type              = "ingress"
  from_port         = 135
  to_port           = 135
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_ldap_rule" {
  type              = "ingress"
  from_port         = 389
  to_port           = 389
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_smb_rule" {
  type              = "ingress"
  from_port         = 445
  to_port           = 445
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_464_rule" {
  type              = "ingress"
  from_port         = 464
  to_port           = 464
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_ldaps_rule" {
  type              = "ingress"
  from_port         = 636
  to_port           = 636
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_gcatalog_rule" {
  type              = "ingress"
  from_port         = 3268
  to_port           = 3269
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_rdp_rule" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_9389_rule" {
  type              = "ingress"
  from_port         = 9389
  to_port           = 9389
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_ephemeralrpc_rule" {
  type              = "ingress"
  from_port         = 49152
  to_port           = 65535
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ad.id
}

resource "aws_security_group_rule" "ad_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ad.id
}