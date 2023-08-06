# README
Script to delete default VPCs in all regions for either a single account or for several accounts with assume role. Requires boto3.

## Usage

    ./delete-default-vpcs.py <aws profile name> [list of role arns...]

    ./delete-default-vpcs.py <customer external id> [list of role arns...]

### Examples

Delete the VPCs in all regions for the account associated with the default AWS credentials profile:

    ./delete-default-vpcs.py default

Delete the VPCs in all regions for two accounts which the project-creds AWS credentials have permission to assume role to:

    ./delete-default-vpcs.py project-creds arn:aws:iam::account-id:role1/role-name arn:aws:iam::account-id:role2/role-name

## Implementation
For each region in each account the script first checks the following:

1. what is the account default VPC ID? If none, exit
2. are there any instances in the default VPC? If yes, exit

If these checks pass, the script does the following:

1. get the DHCP options set ID
2. get and delete all subnets in the VPC
3. get, detach, and delete the VPC Internet Gateway
4. delete the VPC
5. delete the DHCP options set

## Caveats
For a default VPC which has never been used, this script will delete it.

If the VPC has been used in the past and resources still exist, it may not be possible to delete the VPC without first manually deleting those resources. The exception will be printed but the script will continue for the remaining accounts / regions, and the script will exit with code 1.