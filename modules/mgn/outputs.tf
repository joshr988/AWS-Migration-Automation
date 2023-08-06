output "mgn_access_key" {
  value = aws_iam_access_key.mgn_key.id
}

output "mgn_secret_key" {
  value = aws_iam_access_key.mgn_key.encrypted_secret
}

output "mgn_replication" {
  value = aws_security_group.mgn.id
}

output "mgn_test_no_outbound" {
  value = aws_security_group.mgn_test1.id
}

output "mgn_test_vpc_outbound" {
  value = aws_security_group.mgn_test2.id
}

output "mgn_test_sg_outbound" {
  value = aws_security_group.mgn_test3.id
}
