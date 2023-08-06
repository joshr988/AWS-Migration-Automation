############################################
#### required role to get mgn server info
############################################
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "_Lambda_Role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_mgn_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationReadOnlyAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "publish_sns_policy_attachment" {
  policy_arn = aws_iam_policy.publish_sns_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "publish_sns_policy" {
  name        = "Lambda-SNS-Policy"
  description = "Lambda access to publish to sns-topic"
  policy      = data.aws_iam_policy_document.publish_sns_policy_document.json
}

data "aws_iam_policy_document" "publish_sns_policy_document" {

  statement {
    sid = "PublishSNS"
    actions = [
      "sns:Publish",
    ]
    resources = [aws_sns_topic.mgn_topic.arn]
  }
}

############################################
#### Notification lambda function
############################################
data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/scripts/mgn_notification.py"
  output_path = "mgn_notification.zip"
}

resource "aws_lambda_function" "mgn_notification_lambda" {
  function_name    = "mgn_notification"
  filename         = "mgn_notification.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "mgn_notification.lambda_handler"
  timeout          = 10
  environment {
    variables = {
      sns_arn       = aws_sns_topic.mgn_topic.arn,
      customer_name = var.customer_name
    }
  }
}

############################################
#### SNS topic to send email notifiction
############################################

resource "aws_sns_topic" "mgn_topic" {
  name = "mgn-events"
}

resource "aws_sns_topic_subscription" "user_updates_sns" {
  topic_arn = aws_sns_topic.mgn_topic.arn
  protocol  = "email"
  endpoint  = var.target_email
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.mgn_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sns_topic.mgn_topic.arn]
  }
}
