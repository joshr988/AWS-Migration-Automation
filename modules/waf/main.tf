## WAF Deployment Module ##

resource "aws_wafv2_web_acl" "waf_ruleset" {
  name        = var.name
  description = "WAF Rules"
  scope       = var.scope

  default_action {
    allow {}
  }

  tags = var.tags
}

resource "aws_wafv2_ip_set" "vpn-ranges" {
  name               = "VPN-Ranges"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.addresses
}
