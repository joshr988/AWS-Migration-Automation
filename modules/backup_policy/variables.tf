variable "customer_name" {}

variable "schedule" {
  type = map(any)
  default = {
    daily_backup   = "cron(0 05 ? * * *)"
    weekly_backup  = "cron(0 05 ? * SUN *)"
    monthly_backup = "cron(0 05 1 * ? *)"
  }
}