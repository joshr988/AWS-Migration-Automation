resource "aws_iam_role" "ec2ssm" {
  name               = "_EC2_SSM"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "SSM_Profile"
  role = aws_iam_role.ec2ssm.name
}

resource "aws_iam_policy_attachment" "pol_att" {
  name       = "AmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.ec2ssm.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "bastion_sg" {
  count = var.create_sec_group ? 1 : 0
  lifecycle {
    create_before_destroy = true
  }

  name   = "${var.bastion_name}-${var.customer_name}-SG"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ssh" {
  count     = var.set_ssh ? 1 : 0
  type      = "ingress"
  from_port = var.ssh_port
  to_port   = var.ssh_port
  protocol  = "tcp"

  security_group_id = var.security_group
}

resource "aws_security_group_rule" "rdp" {
  count     = var.set_rdp ? 1 : 0
  type      = "ingress"
  from_port = var.rdp_port
  to_port   = var.rdp_port
  protocol  = "tcp"

  security_group_id = var.security_group
}

resource "aws_security_group_rule" "egress" {
  count       = var.set_egress ? 1 : 0
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = var.security_group
}

resource "aws_instance" "bastion" {
  lifecycle {
    ignore_changes = [user_data, ami]
  }
  ami                    = var.linux_bastion ? data.aws_ami.amazon_linux_2.id : data.aws_ami.win2019.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.id
  vpc_security_group_ids = [var.security_group]
  user_data              = var.user_data

  tags = {
    Name = var.bastion_name
  }
}
