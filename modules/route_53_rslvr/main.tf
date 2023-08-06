resource "aws_security_group" "route53_sg" {
  name        = "${var.customer_name}-route53-sg"
  description = "Access to Route53 Resolver."
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "TCP"
    cidr_blocks = var.whitelist
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "UDP"
    cidr_blocks = var.whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "${var.customer_name}-route53-sg"
  }
}

resource "aws_route53_resolver_endpoint" "rslvr-out" {
  name      = "${var.customer_name}-outbound-endpoint"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.route53_sg.id
  ]

  dynamic "ip_address" {
    for_each = var.route53_subnets
    content {
      subnet_id = ip_address.value
    }
  }
}

resource "aws_route53_resolver_endpoint" "rslvr-in" {
  name      = "${var.customer_name}-inbound-endpoint"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.route53_sg.id
  ]

  dynamic "ip_address" {
    for_each = var.route53_subnets
    content {
      subnet_id = ip_address.value
    }
  }
}

resource "aws_route53_resolver_rule" "fwd" {
  for_each             = { for idx, dm in var.customer_domain : idx => dm }
  domain_name          = each.value
  name                 = replace(each.value, ".", "-")
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.rslvr-out.id

  dynamic "target_ip" {
    for_each = var.customer_dns_ips
    content {
      ip = target_ip.value
    }
  }
}

resource "aws_route53_resolver_rule_association" "rslvr_association" {
  for_each         = aws_route53_resolver_rule.fwd
  resolver_rule_id = each.value.id
  vpc_id           = data.aws_vpc.vpc.id
}

# resource "aws_route53_resolver_rule" "fwd" {
#   domain_name          = var.customer_domain
#   name                 = replace(var.customer_domain, ".", "-")
#   rule_type            = "FORWARD"
#   resolver_endpoint_id = aws_route53_resolver_endpoint.rslvr-out.id

#   dynamic "target_ip" {
#     for_each = var.customer_dns_ips
#     content {
#       ip = target_ip.value
#     }
#   }
# }

# resource "aws_route53_resolver_rule_association" "rslvr_association" {
#   resolver_rule_id = aws_route53_resolver_rule.fwd.id
#   vpc_id           = data.aws_vpc.vpc.id
# }
