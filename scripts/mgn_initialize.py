#!/usr/bin/env python3

import boto3
import sys
import fire
import questionary
import inquirer as re

from questionary.constants import YES, YES_OR_NO

def client(credentials):
    client = boto3.client(  
        'mgn',
            aws_access_key_id=credentials.get('AccessKeyId'),
            aws_secret_access_key=credentials.get('SecretAccessKey'),
            aws_session_token=credentials.get('SessionToken'),
            region_name='us-east-1'
        )

    return client

def mgn_initialize():
    mgn_initialize = client.initialize_service()

    return mgn_initialize

response = client.update_launch_configuration(
    bootMode='UEFI',
    copyPrivateIp=False,
    copyTags=False,
    launchDisposition='STOPPED',
    licensing={
        'osByol': False
    },
    name='string',
    sourceServerID='string',
    targetInstanceTypeRightSizingMethod='BASIC'
)


# def update_launch_configuration():

# launch_configuration = client.update_launch_configuration(

#     bootMode =
#          re.Checkbox('bootMode',
#                 message = "What is the Boot Mode?",
#                 choices = ['LEGACY_BIOS', 'UEFI'],
# ),
#     answers = re.prompt(bootMode),
#         # bootMode='LEGACY_BIOS'|'UEFI',
#     copyPrivateIp=False,
#     copyTags=False,
#     launchDisposition='STOPPED',
#     licensing={
#         'osByol': False
#     },
#     name='string',
#     sourceServerID='string',
#     targetInstanceTypeRightSizingMethod='NONE'
#     )

    #     copyPrivateIp=True|False,
    # copyTags=True|False,
    # launchDisposition='STOPPED'|'STARTED',
    # licensing={
    #     'osByol': True|False
    # },
    # name='string',
    # sourceServerID='string',
    # targetInstanceTypeRightSizingMethod='NONE'|'BASIC'

    # return launch_configuration

# def update_replication_configuration():

#     replication_configuration = client.update_replication_configuration(
#         associateDefaultSecurityGroup=True|False,
#         bandwidthThrottling=123,
#         createPublicIP=True|False,
#         dataPlaneRouting='PRIVATE_IP'|'PUBLIC_IP',
#         defaultLargeStagingDiskType='GP2'|'ST1'|'GP3',
#         ebsEncryption='DEFAULT'|'CUSTOM',
#         ebsEncryptionKeyArn='string',
#         name='string',
#         replicatedDisks=[
#             {
#                 'deviceName': 'string',
#                 'iops': 123,
#                 'isBootDisk': True|False,
#                 'stagingDiskType': 'AUTO'|'GP2'|'IO1'|'SC1'|'ST1'|'STANDARD'|'GP3'|'IO2',
#                 'throughput': 123
#             },
#         ],
#         replicationServerInstanceType='string',
#         replicationServersSecurityGroupsIDs=[
#             'string',
#         ],
#         sourceServerID='string',
#         stagingAreaSubnetId='string',
#         stagingAreaTags={
#             'string': 'string'
#         },
#         useDedicatedReplicationServer=True|False
#     )

#     return replication_configuration