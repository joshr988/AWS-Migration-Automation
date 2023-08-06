# data "aws_ami" "win2019" {
#   owners      = ["amazon"]
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["Windows_Server-2019-English-Full-Base-*"]
#   }
# }

data "aws_ami" "onramp" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

# data "aws_ami" "amazn2Linux" {
#   owners      = ["amazon"]
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*"]
#   }
# }
