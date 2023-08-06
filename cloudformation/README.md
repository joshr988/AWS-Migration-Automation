## Deploy Roles Cloudformation using AWS Cloudshell
`aws cloudformation create-stack --template-url https://cloudamize-onramp-public.s3.us-east-2.amazonaws.com/cloudamize-iam-roles.yml --stack-name onramp-automation-roles --capabilities CAPABILITY\_NAMED\_IAM --parameters ParameterKey=externalID,ParameterValue=onramp123`

## Deploy S3-Dynamo Backend using AWS Cloudshell
`aws cloudformation create-stack --template-url https://cloudamize-onramp-public.s3.us-east-2.amazonaws.com/s3-dynamo-backend-config.yml  --stack-name terraform-backend --parameters ParameterKey=CustomerName,ParameterValue=onramp ParameterKey=Region,ParameterValue=us-east-1`