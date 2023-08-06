## MGN Initialization Config - IAM Roles & Policies

resource "aws_iam_role" "replication_role" {
  name               = "AWSApplicationMigrationReplicationServerRole"
  path               = "/service-role/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_instance_profile" "replication_role" {
  name = "AWSApplicationMigrationReplicationServerRole"
  role = aws_iam_role.replication_role.name
}

##############

resource "aws_iam_role" "conversion_role" {
  name               = "AWSApplicationMigrationConversionServerRole"
  path               = "/service-role/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_instance_profile" "conversion_role" {
  name = "AWSApplicationMigrationConversionServerRole"
  role = aws_iam_role.conversion_role.name
}

##############

resource "aws_iam_role" "migration_role" {
  name               = "AWSApplicationMigrationMGHRole"
  path               = "/service-role/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["mgn.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSApplicationMigrationReplicationServerPolicy"
  role       = aws_iam_role.replication_role.name
}

resource "aws_iam_role_policy_attachment" "conversion" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSApplicationMigrationConversionServerPolicy"
  role       = aws_iam_role.conversion_role.name
}

resource "aws_iam_role_policy_attachment" "migration" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSApplicationMigrationMGHAccess"
  role       = aws_iam_role.migration_role.name
}


#IAM Role and Keys

data "local_file" "pgp_key" {
  filename = "tfpublickey.gpg"
}

resource "aws_iam_user" "mgn_user" {
  name = var.mgn_user
  path = "/"
}

resource "aws_iam_access_key" "mgn_key" {
  user    = aws_iam_user.mgn_user.name
  pgp_key = data.local_file.pgp_key.content_base64
}

resource "aws_iam_user_policy_attachment" "mgn_att" {
  user       = aws_iam_user.mgn_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationAgentPolicy"
}

############ MGN Notification ############

############################################
#### Event rule - STALLED
############################################
resource "aws_cloudwatch_event_rule" "stalled" {
  name          = "mgn-stalled"
  description   = "Capture MGN events"
  event_pattern = <<EOF
      {
        "source": [
          "aws.mgn"
        ],
        "detail": {
          "state": [
            "STALLED"
          ]
        }
      }
  EOF
}

resource "aws_cloudwatch_event_target" "stalled_target" {
  rule = aws_cloudwatch_event_rule.stalled.name
  arn  = aws_lambda_function.mgn_notification_lambda.arn
}

############################################
#### Event rule - READY_FOR_TEST
############################################
resource "aws_cloudwatch_event_rule" "test_ready" {
  name          = "mgn-ready-for-test"
  description   = "Capture MGN events"
  event_pattern = <<EOF
      {
        "source": [
          "aws.mgn"
        ],
        "detail": {
          "state": [
            "READY_FOR_TEST"
          ]
        }
      }
  EOF
}

resource "aws_cloudwatch_event_target" "test_ready_target" {
  rule = aws_cloudwatch_event_rule.test_ready.name
  arn  = aws_lambda_function.mgn_notification_lambda.arn
}

############################################
#### Event rule - TEST_LAUNCH_SUCCEEDED
############################################
resource "aws_cloudwatch_event_rule" "test_launch_succeed" {
  name          = "mgn-successful-test"
  description   = "Capture MGN events"
  event_pattern = <<EOF
      {
        "source": [
          "aws.mgn"
        ],
        "detail": {
          "state": [
            "TEST_LAUNCH_SUCCEEDED"
          ]
        }
      }
  EOF
}

resource "aws_cloudwatch_event_target" "test_launch_succeed_target" {
  rule = aws_cloudwatch_event_rule.test_launch_succeed.name
  arn  = aws_lambda_function.mgn_notification_lambda.arn
}

############################################
#### Event rule - TEST_LAUNCH_FAILED
############################################
resource "aws_cloudwatch_event_rule" "test_launch_failed" {
  name          = "mgn-failed-test"
  description   = "Capture MGN events"
  event_pattern = <<EOF
      {
        "source": [
          "aws.mgn"
        ],
        "detail": {
          "state": [
            "TEST_LAUNCH_FAILED"
          ]
        }
      }
  EOF
}

resource "aws_cloudwatch_event_target" "test_launch_failed_target" {
  rule = aws_cloudwatch_event_rule.test_launch_failed.name
  arn  = aws_lambda_function.mgn_notification_lambda.arn
}

############################################
#### Event rule - CUTOVER_LAUNCH_SUCCEEDED
############################################
resource "aws_cloudwatch_event_rule" "cutover_launch_succeed" {
  name          = "mgn-successful-cutover"
  description   = "Capture MGN events"
  event_pattern = <<EOF
      {
        "source": [
          "aws.mgn"
        ],
        "detail": {
          "state": [
            "CUTOVER_LAUNCH_SUCCEEDED"
          ]
        }
      }
  EOF
}

resource "aws_cloudwatch_event_target" "sns" {
  rule = aws_cloudwatch_event_rule.cutover_launch_succeed.name
  arn  = aws_lambda_function.mgn_notification_lambda.arn
}

############################################
#### Event rule - CUTOVER_LAUNCH_FAILED
############################################
resource "aws_cloudwatch_event_rule" "cutover_launch_failed" {
  name          = "mgn-failed-cutover"
  description   = "Capture MGN events"
  event_pattern = <<EOF
      {
        "source": [
          "aws.mgn"
        ],
        "detail": {
          "state": [
            "CUTOVER_LAUNCH_FAILED"
          ]
        }
      }
  EOF
}

resource "aws_cloudwatch_event_target" "cutover_launch_failed_target" {
  rule = aws_cloudwatch_event_rule.cutover_launch_failed.name
  arn  = aws_lambda_function.mgn_notification_lambda.arn
}
