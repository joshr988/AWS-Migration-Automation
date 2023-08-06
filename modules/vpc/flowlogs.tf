# Enable VPC Flow logs

resource "aws_flow_log" "flow_logs" {
  iam_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/_Service-VPCFlowLogs"
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.vpc_name}-Flow_logs"
  }
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name = lower(format("flgg-%s-%s", var.vpc_name, var.env))
}

resource "aws_iam_role" "flow_logs" {
  name = "_Service-VPCFlowLogs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",  
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "_Vpc-flow-log-policy"
  role = aws_iam_role.flow_logs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
