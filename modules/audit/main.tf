#####################
## AWS CLOUD TRAIL ##
#####################

data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "${var.customer_name}-Trail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.bucket
  s3_key_prefix                 = "trail"
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_s3_bucket" "trail_bucket" {
  bucket        = "${var.customer_bucket}-auditlogs-${var.bucket_date_created}"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.customer_bucket}-auditlogs-${var.bucket_date_created}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.customer_bucket}-auditlogs-${var.bucket_date_created}/trail/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.trail_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

###################
#### AWS CONFIG ###
###################

resource "aws_config_delivery_channel" "config" {
  name           = "${var.customer_name}-DeliveryChannel"
  s3_bucket_name = aws_s3_bucket.trail_bucket.bucket
  s3_key_prefix  = "config"
  depends_on     = [aws_config_configuration_recorder.config]
}

resource "aws_config_configuration_recorder" "config" {
  name     = "${var.customer_name}-Recorder"
  role_arn = aws_iam_role.r.arn
}

resource "aws_iam_role" "r" {
  name = "_AWS_Config_Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "trail_bucket" {
  name = "_AWS_Config_Policy"
  role = aws_iam_role.r.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.trail_bucket.arn}",
        "${aws_s3_bucket.trail_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}
