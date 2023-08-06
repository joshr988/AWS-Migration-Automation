# Creates a security group that allow SSH from user-specified IP addrress, and all outbond traffic
resource "aws_security_group" "ssh_admin" {
  name        = "${var.account_name}-linux-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    "Name" : "${var.account_name}-linux-sg"
  }
}

resource "aws_security_group_rule" "lnx_icmp_rule" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "ICMP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ssh_admin.id
}

resource "aws_security_group_rule" "lnx_ssh_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.ssh_admin.id
}

resource "aws_security_group_rule" "lnx_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh_admin.id
}

# Creates a security group that allow RDP from user-specified IP addrress, and all outbond traffic
resource "aws_security_group" "rdp_admin" {
  name        = "${var.account_name}-windows-sg"
  description = "Allow RDP"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    "Name" : "${var.account_name}-windows-sg"
  }
}

resource "aws_security_group_rule" "win_rdp_rule" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.rdp_admin.id
}

resource "aws_security_group_rule" "win_icmp_rule" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "ICMP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.rdp_admin.id
}

resource "aws_security_group_rule" "win_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rdp_admin.id
}

# Creates a security group that allow endpoints access
resource "aws_security_group" "endpoint" {
  name        = "${var.account_name}-endpoint-sg"
  description = "Allow endpoint access."
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.whitelist
  }

  tags = {
    "Name" : "${var.account_name}-endpoint-sg"
  }
}
