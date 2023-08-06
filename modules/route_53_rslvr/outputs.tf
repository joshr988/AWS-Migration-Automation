output "aws_route53_resolver_rule_ID" {
  value = values(aws_route53_resolver_rule.fwd)[*].id
}

output "aws_route53_resolver_fwd_rule" {
  value = aws_route53_resolver_rule.fwd
}
