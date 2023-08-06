# data "aws_iam_policy_document" "ec2_assume_role" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "sts:AssumeRole"
#     ]

#     principals {
#       type = "Service"
#       identifiers = [
#         "ec2.amazonaws.com",
#       ]
#     }
#   }
# }

# resource "aws_iam_role" "ec2ssm" {
#   name               = "_EC2_SSM_Role"
#   assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
# }

# resource "aws_iam_instance_profile" "ec2_ssm_profile" {
#   name_prefix = "SSM_Profile"
#   role        = aws_iam_role.ec2ssm.name
# }

# resource "aws_iam_role_policy_attachment" "ssm_pol_att" {
#   role       = aws_iam_role.ec2ssm.id
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_role_policy_attachment" "cloudwatch_pol_att" {
#   role       = aws_iam_role.ec2ssm.id
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }
