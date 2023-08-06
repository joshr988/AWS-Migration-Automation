# Creates security groups MGN replication
resource "aws_security_group" "mgn" {
  name        = "AWS Application Migration Service Replication Server Security Group"
  description = "Security group with the required permissions for AWS Application Migration Service Replication Servers"
  vpc_id      = var.vpc_id

  tags = {
    "Name" : "AWS Application Migration Service Replication Server Security Group"
  }
}

resource "aws_security_group_rule" "mgn_1500_rule" {
  type              = "ingress"
  from_port         = 1500
  to_port           = 1500
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn.id
}

resource "aws_security_group_rule" "mgn_egress_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn.id
}

resource "aws_security_group_rule" "mgn_egress_dns" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "UDP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn.id
}

# Creates security groups for MGN test, no outbound, outbound traffic limited to the VPC cidr and SG only traffic.
resource "aws_security_group" "mgn_test1" {
  name        = "${var.customer_name}-mgn-test-no-outbound"
  description = "Access to SSH, RDP."
  vpc_id      = var.vpc_id

  tags = {
    "Name" : "${var.customer_name}-mgn-test-no-outbound"
  }
}

resource "aws_security_group_rule" "mgn_icmp_rule" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "ICMP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn_test1.id
}

resource "aws_security_group_rule" "mgn_ssh_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn_test1.id
}

resource "aws_security_group_rule" "mgn_rdp_rule" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn_test1.id
}

####

resource "aws_security_group" "mgn_test2" {
  name        = "${var.customer_name}-mgn-test-vpc-outbound"
  description = "Access to SSH, RDP."
  vpc_id      = var.vpc_id

  tags = {
    "Name" : "${var.customer_name}-mgn-test-vpc-outbound"
  }
}

resource "aws_security_group_rule" "mgn_icmp_rule2" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "ICMP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn_test2.id
}

resource "aws_security_group_rule" "mgn_ssh_rule2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn_test2.id
}

resource "aws_security_group_rule" "mgn_rdp_rule2" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "TCP"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn_test2.id
}

resource "aws_security_group_rule" "mgn_egress_rule2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.whitelist
  security_group_id = aws_security_group.mgn_test2.id
}

####

resource "aws_security_group" "mgn_test3" {
  name        = "${var.customer_name}-mgn-test-sg-outbound"
  description = "Access to SSH, RDP."
  vpc_id      = var.vpc_id

  tags = {
    "Name" : "${var.customer_name}-mgn-test-sg-outbound"
  }
}

resource "aws_security_group_rule" "mgn_icmp_rule3" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "ICMP"
  source_security_group_id = aws_security_group.mgn_test3.id
  security_group_id        = aws_security_group.mgn_test3.id
}

resource "aws_security_group_rule" "mgn_ssh_rule3" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.mgn_test3.id
  security_group_id        = aws_security_group.mgn_test3.id
}

resource "aws_security_group_rule" "mgn_rdp_rule3" {
  type                     = "ingress"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.mgn_test3.id
  security_group_id        = aws_security_group.mgn_test3.id
}

resource "aws_security_group_rule" "mgn_egress_rule3" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.mgn_test3.id
  security_group_id        = aws_security_group.mgn_test3.id
}
