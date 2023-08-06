resource "aws_backup_vault" "backup_vault" {
  name = "${var.customer_name}-Vault"
}

resource "aws_backup_vault_policy" "backup_policy" {
  backup_vault_name = aws_backup_vault.backup_vault.name
  policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "default",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "backup:DescribeBackupVault",
        "backup:DeleteBackupVault",
        "backup:PutBackupVaultAccessPolicy",
        "backup:DeleteBackupVaultAccessPolicy",
        "backup:GetBackupVaultAccessPolicy",
        "backup:StartBackupJob",
        "backup:GetBackupVaultNotifications",
        "backup:PutBackupVaultNotifications"
      ],
      "Resource": "${aws_backup_vault.backup_vault.arn}"
    }
  ]
}
POLICY
}

resource "aws_backup_plan" "backup_plan" {
  name = "${var.customer_name}-Backup-Plan"

  rule {
    rule_name         = "Daily_Backup"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = var.schedule.daily_backup
    start_window      = 60

    lifecycle {
      delete_after = "30"
    }
  }

  rule {
    rule_name         = "Weekly_Backup"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = var.schedule.weekly_backup
    start_window      = 60

    lifecycle {
      delete_after = "90"
    }
  }

  rule {
    rule_name         = "Monthly_Backup"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = var.schedule.monthly_backup
    start_window      = 60

    lifecycle {
      delete_after       = "365"
      cold_storage_after = "90"
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }
}

# resource "aws_backup_region_settings" "region" {
#   resource_type_opt_in_preference = {
#     "DynamoDB"        = true
#     "Aurora"          = true
#     "EBS"             = true
#     "EC2"             = true
#     "EFS"             = true
#     "FSx"             = true
#     "RDS"             = true
#     "Storage Gateway" = true
#   }
# }

resource "aws_iam_role" "backup_role" {
  name               = "_Backup_Role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_backup_selection" "backup" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.customer_name}-Backup-Selection"
  plan_id      = aws_backup_plan.backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "True"
  }
}
