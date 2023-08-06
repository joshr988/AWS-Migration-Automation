# Maximum number of vCPUs assigned to the Running On-Demand Standard 
resource "aws_servicequotas_service_quota" "vcpu_increase" {
  quota_code   = data.aws_servicequotas_service_quota.vcpu_increase_data.quota_code
  service_code = data.aws_servicequotas_service_quota.vcpu_increase_data.service_code
  value        = var.vcpu_increase_value
}

# The maximum number of events that functions can process simultaneously in the current Region.
resource "aws_servicequotas_service_quota" "lambda_concurrent_increase" {
  quota_code   = data.aws_servicequotas_service_quota.lambda_concurrent_increase_data.quota_code
  service_code = data.aws_servicequotas_service_quota.lambda_concurrent_increase_data.service_code
  value        = var.lambda_concurrent_increase_value
}

# The maximum aggregated amount of storage, in TiB, that can be provisioned across General Purpose SSD (gp3) volumes in this Region.
resource "aws_servicequotas_service_quota" "ebs_storage_increase" {
  quota_code   = data.aws_servicequotas_service_quota.ebs_storage_increase_data.quota_code
  service_code = data.aws_servicequotas_service_quota.ebs_storage_increase_data.service_code
  value        = var.ebs_storage_increase_value
}