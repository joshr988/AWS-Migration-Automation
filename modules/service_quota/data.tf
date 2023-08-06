data "aws_servicequotas_service_quota" "vcpu_increase_data" {
  quota_code   = "L-1216C47A"
  service_code = "ec2"
}

data "aws_servicequotas_service_quota" "lambda_concurrent_increase_data" {
  quota_code   = "L-B99A9384"
  service_code = "lambda"
}

data "aws_servicequotas_service_quota" "ebs_storage_increase_data" {
  quota_code   = "L-7A658B76"
  service_code = "ebs"
}