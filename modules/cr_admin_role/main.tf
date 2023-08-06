data "template_file" "task_execution_assume_role_policy" {
  template = file("${path.module}/templates/iam/cr-billing-admin-role-trust.json.tpl")
  vars = {
    root_account_id = var.root_account_id
  }
}

resource "aws_iam_role" "admin_role" {
  name               = "CloudreachAdminRole"
  assume_role_policy = data.template_file.task_execution_assume_role_policy.rendered
}

data "aws_iam_policy" "aws_managed_administrator" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "admin_administrator_policy_attachment" {
  policy_arn = data.aws_iam_policy.aws_managed_administrator.arn
  role       = aws_iam_role.admin_role.id
}
