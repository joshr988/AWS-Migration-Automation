## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.ak](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.c_pol](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_user.c_endure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.admin_att](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.c_att](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_security_group.cloud_endure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IAM_Admin"></a> [IAM\_Admin](#input\_IAM\_Admin) | Admin Policy | `string` | `"arn:aws:iam::aws:policy/AdministratorAccess"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |
| <a name="input_whitelist"></a> [whitelist](#input\_whitelist) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_c_endure_ak"></a> [c\_endure\_ak](#output\_c\_endure\_ak) | n/a |
| <a name="output_c_endure_sg"></a> [c\_endure\_sg](#output\_c\_endure\_sg) | n/a |
| <a name="output_c_endure_sk"></a> [c\_endure\_sk](#output\_c\_endure\_sk) | n/a |
