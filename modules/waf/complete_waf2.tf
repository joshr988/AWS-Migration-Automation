resource "aws_wafv2_web_acl" "waf" {
  name        = var.name
  description = var.description
  scope       = var.scope

  default_action {
    allow {}
  }

  # sample rule which has its own visibility
  rule {
    name     = "Rule-1-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
          name = "NoUserAgent_HEADER"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet-Metric"
      sampled_requests_enabled   = true
    }
  }

  # example of rate-base rule
  //  rule {
  //    name     = "IP-Rate-limit"
  //    priority = 2
  //
  //      action {
  //      block {}
  //    }
  //
  //    statement {
  //      rate_based_statement {
  //        limit              = 500
  //        aggregate_key_type = "IP"
  //
  //        scope_down_statement {
  //          geo_match_statement {
  //            country_codes = ["US"]
  //          }
  //        }
  //      }
  //    }
  //
  //    visibility_config {
  //      cloudwatch_metrics_enabled = true
  //      metric_name                = "IpRateLimit-Metric"
  //      sampled_requests_enabled   = true
  //    }
  //  }

  rule {
    name     = "Rule-2-AWSManagedRulesAdminProtectionRuleSet"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
          name = "NoUserAgent_HEADER"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAdminProtectionRuleSet-Metric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Rule-3-AWSManagedRulesBotControlRuleSet"
    priority = 4

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
          name = "NoUserAgent_HEADER"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesBotControlRuleSet-Metric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "Waf-Metrics"
    sampled_requests_enabled   = true
  }
}
