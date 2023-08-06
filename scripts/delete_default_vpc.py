#!/usr/bin/env python3

import sys
import boto3
import botocore

exit_code = 0


def delete_vpcs_in_account(credentials):

    # create client for getting regions
    ec2_client = boto3.client(
        'ec2',
        aws_access_key_id=credentials.get('AccessKeyId'),
        aws_secret_access_key=credentials.get('SecretAccessKey'),
        aws_session_token=credentials.get('SessionToken'),
        region_name='us-east-1'
    )

    # make list of regions
    region_list = [
        region['RegionName'] for region
        in ec2_client.describe_regions()['Regions']
    ]

    # for each region run delete_vpc_in_region()
    for region_name in region_list:
        print("-- " + region_name + "... ")
        try:
            delete_vpc_in_region(credentials, region_name)
        except botocore.exceptions.ClientError as e:
            print("ERROR - " + str(e))
            exit_code = 1


def delete_vpc_in_region(credentials, region_name):

    # create region specific client
    ec2_client_region = boto3.client(
        'ec2',
        aws_access_key_id=credentials.get('AccessKeyId'),
        aws_secret_access_key=credentials.get('SecretAccessKey'),
        aws_session_token=credentials.get('SessionToken'),
        region_name=region_name
    )

    # get default vpc id
    acccount_attributes = ec2_client_region.describe_account_attributes(
        AttributeNames=['default-vpc'])
    acccount_attribute_values = acccount_attributes['AccountAttributes'][0]['AttributeValues']
    default_vpc = acccount_attribute_values[0]['AttributeValue']

    # return if no default-vpc exists
    if default_vpc == "none":
        print("OK - no default vpc")
        return

    # get instances in default vpc
    # no pagination as > 0 is sufficient to prevent vpc deletion
    vpc_instances_response = ec2_client_region.describe_instances(
        Filters=[{"Name": "vpc-id", "Values": [default_vpc]}])

    # return if instances exist in the default vpc
    if vpc_instances_response['Reservations']:
        print("ERROR - instances exist in this vpc")
        return

    # find dhcp options, delete later as dependent on vpc
    vpc_dhcp_options = ec2_client_region.describe_vpcs(
        VpcIds=[default_vpc])['Vpcs'][0]['DhcpOptionsId']

    # find, and delete subnets
    vpc_subnets_responses = ec2_client_region.describe_subnets(
        Filters=[{"Name": "vpc-id", "Values": [default_vpc]}])

    vpc_subnet_list = [
        vpc_subnet['SubnetId'] for vpc_subnet in vpc_subnets_responses['Subnets']
    ]

    if vpc_subnet_list:
        for subnet in vpc_subnet_list:
            print(subnet)
            ec2_client_region.delete_subnet(SubnetId=subnet)

    # find, detach, and delete internet gateway
    vpc_igw_response = ec2_client_region.describe_internet_gateways(
        Filters=[{"Name": "attachment.vpc-id", "Values": [default_vpc]}])

    vpc_igw_list = [
        vpc_igw['InternetGatewayId'] for vpc_igw in vpc_igw_response['InternetGateways']
    ]

    if vpc_igw_list:
        for vpc_igw in vpc_igw_list:
            print(vpc_igw)
            ec2_client_region.detach_internet_gateway(
                InternetGatewayId=vpc_igw, VpcId=default_vpc)
            ec2_client_region.delete_internet_gateway(
                InternetGatewayId=vpc_igw)

    # delete vpc
    print(default_vpc)
    ec2_client_region.delete_vpc(VpcId=default_vpc)

    # delete dhcp options
    print(vpc_dhcp_options)
    ec2_client_region.delete_dhcp_options(DhcpOptionsId=vpc_dhcp_options)

    print("OK")


if __name__ == "__main__":

    # require explicit input for profile. all proceeding args are role arns
    if len(sys.argv) == 1:
        print("please explicitly specify profile name")
        sys.exit(2)
    else:
        session = boto3.Session(
            region_name="us-east-1"
        )
        role_arns = sys.argv[2:]

    # if list of role_arns is empty, run delete_default_vpcs on profile account
    # else run delete_default_vpcs on each role arn account
    if not role_arns:

        get_credentials = session.get_credentials()
        credentials = {
            'AccessKeyId': get_credentials.access_key,
            'SecretAccessKey': get_credentials.secret_key
        }
        delete_vpcs_in_account(credentials)

    else:

        for role_arn in role_arns:

            sts_client = session.client('sts')

            # http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-api.html
            # Call the assume_role method of the STSConnection object and pass
            # the role ARN and a role session name.
            assumedRoleObject = sts_client.assume_role(
                RoleArn=role_arn,
                RoleSessionName="delete_default_vpcs",
                ExternalId=sys.argv[1]
            )

            # From the response that contains the assumed role, get the temp
            # credentials that can be used to make subsequent API calls
            credentials = {
                'AccessKeyId': assumedRoleObject['Credentials']['AccessKeyId'],
                'SecretAccessKey': assumedRoleObject['Credentials']['SecretAccessKey'],
                'SessionToken': assumedRoleObject['Credentials']['SessionToken']
            }
            print("---- " + role_arn)
            delete_vpcs_in_account(credentials)

sys.exit(exit_code)
