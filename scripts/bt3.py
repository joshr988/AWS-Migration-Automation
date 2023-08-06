import json
import urllib.parse
import boto3
import csv
import io
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.resource('s3')
ec2 = boto3.client('ec2')
mgn = boto3.client('mgn')
env = 'TEST'
instance_profile ='arn:aws:iam::049152880445:instance-profile/AWSApplicationMigrationConversionServerRole'


#main event handler
def lambda_handler(event, context):
    
    #opens CSV from bucket and extracts fields into dictionary (list_of_json[1:])
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    csv_object = s3.Object(bucket, key)
    csv_file = csv_object.get()['Body'].read().decode('utf-8')
    
    f = io.StringIO(csv_file)
    reader = csv.DictReader(f, ('ID', 'Status', 'Source Server Name','Target Server Name', 'Environment', 'Oracle Database Used', 'Application', 'Target Server VM Size', 'Operating System', 'OS Version', 'Target Account', 'Target Availablity Zone','Target VPC', 'Target Subnet', 'License on-prem', 'License in AWS', 'Strategy', 'Maintenance (Cutover) Window,', 'EBS type', 'Tags', 'Security group' ))
    list_of_json = [dict(device) for device in reader]
   
    f.close() 
    #gets list of source server ids and maps to hostname
    lt_hostname_map = map_lt_to_hostname(get_source_server_ids())
    
    #gets narrowed lists (no repeats, removes unnecessary fields, and changes certain field names)
    lt_narrowed_list = get_lt_narrowed_list(list_of_json[1:])
    
    
    combined_map = combined_dict_list(lt_narrowed_list,lt_hostname_map)
    
    response = modify_lts(combined_map)
    
    
    return(response)

#union the two dicts where the hostname in each is the same
def combined_dict_list(narrowed_list,lt_hostname_map):
    combined_map_list=[]
    for i in narrowed_list:
        for j in lt_hostname_map:
            combined_map_dict={}
            if i['hostname'] == j['hostname']:
                #union of two dicts 
                combined_map_dict = i | j 
                combined_map_list.append(combined_map_dict.copy())
    return combined_map_list


#get MGN source server ids and hostnames
def get_source_server_ids():
    source_server_list=[]
    
    
    response = mgn.describe_source_servers(filters={}) 
    print('mgn')
    print(json.dumps(response['items']))
    for i in response['items']:
        source_server_dict={}
        source_server_dict['sourceServerID'] =i['sourceServerID']
        source_server_dict['hostname'] = i['sourceProperties']['identificationHints']['hostname'].split('.',1)[0]
        source_server_list.append(source_server_dict.copy())
    return(source_server_list)



def get_lt_narrowed_list(lt_list):

    narrowed_lt_list =[]
    for i in lt_list:

        if i['Environment'] and i['Operating System'] and i['Target Server VM Size'] and i['Target Subnet'] and i['Target VPC'] and i['Target Server Name'] :
            
            if i['Environment']  == env:
                pass
            else: 
                continue
            

            temp_dict={}
            #temp_dict['Instance Name'] = i['Instance Name']
            temp_dict['Environment'] = i['Environment']
            temp_dict['Operating System'] = i['Operating System']
            temp_dict['Target Server VM Size'] = i['Target Server VM Size']
            temp_dict['Target Subnet'] = i['Target Subnet']
            temp_dict['Target VPC'] = i['Target VPC']
            temp_dict['Tags'] = i['Tags']
            temp_dict['hostname'] = i['Target Server Name'].split('.',1)[0]
            
        else:
            logger.info("malformed json")
        
            
        if temp_dict in narrowed_lt_list:
            continue
        else:
            narrowed_lt_list.append(temp_dict)

    return narrowed_lt_list
            

def map_lt_to_hostname(ss_dict):
    hostname_lt_map_list=[]
    for i in ss_dict:
        hostname_lt_map_dict={}
        response = mgn.get_launch_configuration(
            sourceServerID=i['sourceServerID']
        )


        hostname_lt_map_dict['ec2LaunchTemplateID'] = response['ec2LaunchTemplateID']
        hostname_lt_map_dict['hostname'] = i['hostname']
        hostname_lt_map_list.append(hostname_lt_map_dict.copy())
    return hostname_lt_map_list
            
def modify_lts(lt_list):

    for i in lt_list:
        response = ec2.create_launch_template_version(
            #DryRun=True|False,
            #ClientToken='string',
            #LaunchTemplateName=i['Recommended Instance'] + '-' + 'lt' + '-' + env,
            LaunchTemplateId=i['ec2LaunchTemplateID'],
            VersionDescription='string',
            LaunchTemplateData={
                #'KernelId': 'string',
                'EbsOptimized': True,
                'IamInstanceProfile': {
                    'Arn': instance_profile
                },
                'BlockDeviceMappings': [
                    {
                        'DeviceName': 'string',
                        'VirtualName': 'string',
                        'Ebs': {
                            'Encrypted': True,
                            'DeleteOnTermination': True,
                            #'Iops': 123,
                            #'KmsKeyId': 'string',
                            #'SnapshotId': 'string',
                            'VolumeType': 'gp3',
                        }
                        #'NoDevice': 'string'
                    }
                ],
                'NetworkInterfaces': [
                    {
                        'AssociateCarrierIpAddress': False,
                        'AssociatePublicIpAddress': False,
                        'DeleteOnTermination': True
                        #'Description': 'string',
                        #'DeviceIndex': 123,
                        #'Groups': [
                        #     'string',
                        
                        # ],
                        # 'InterfaceType': 'string',
                        # 'Ipv6AddressCount': 123,
                        # 'Ipv6Addresses': [
                        #     {
                        #         'Ipv6Address': 'string'
                        #     },
                        # ],
                        # 'NetworkInterfaceId': 'string',
                        # 'PrivateIpAddress': 'string',
                        # 'PrivateIpAddresses': [
                        #     {
                        #         'Primary': True|False,
                        #         'PrivateIpAddress': 'string'
                        #     },
                        # ],
                        # 'SecondaryPrivateIpAddressCount': 123,
                        # 'SubnetId': 'string',
                        # 'NetworkCardIndex': 123,
                        # 'Ipv4Prefixes': [
                        #     {
                        #         'Ipv4Prefix': 'string'
                        #     },
                        # ],
                        # 'Ipv4PrefixCount': 123,
                        # 'Ipv6Prefixes': [
                        #     {
                        #         'Ipv6Prefix': 'string'
                        #     },
                        # ],
                        # 'Ipv6PrefixCount': 123
                    }
                ],
                #'ImageId': 'string',
                'InstanceType': i['Target Server VM Size'],
                'KeyName': 'string',
                'Monitoring': {
                    'Enabled': True
                },
                'SecurityGroupIds': [
                    'sg-000d1516e27a63614'
                ]
                # 'Placement': {
                #     'AvailabilityZone': 'string',
                #     'Affinity': 'string',
                #     'GroupName': 'string',
                #     'HostId': 'string',
                #     'Tenancy': 'default'|'dedicated'|'host',
                #     'SpreadDomain': 'string',
                #     'HostResourceGroupArn': 'string',
                #     'PartitionNumber': 123
                # },
                # 'RamDiskId': 'string',
                # 'DisableApiTermination': True|False,
                # 'InstanceInitiatedShutdownBehavior': 'stop'|'terminate',
                # 'UserData': 'string',
                # 'TagSpecifications': [
                #     {
                #         'ResourceType': 'capacity-reservation'|'client-vpn-endpoint'|'customer-gateway'|'carrier-gateway'|'dedicated-host'|'dhcp-options'|'egress-only-internet-gateway'|'elastic-ip'|'elastic-gpu'|'export-image-task'|'export-instance-task'|'fleet'|'fpga-image'|'host-reservation'|'image'|'import-image-task'|'import-snapshot-task'|'instance'|'instance-event-window'|'internet-gateway'|'ipam'|'ipam-pool'|'ipam-scope'|'ipv4pool-ec2'|'ipv6pool-ec2'|'key-pair'|'launch-template'|'local-gateway'|'local-gateway-route-table'|'local-gateway-virtual-interface'|'local-gateway-virtual-interface-group'|'local-gateway-route-table-vpc-association'|'local-gateway-route-table-virtual-interface-group-association'|'natgateway'|'network-acl'|'network-interface'|'network-insights-analysis'|'network-insights-path'|'network-insights-access-scope'|'network-insights-access-scope-analysis'|'placement-group'|'prefix-list'|'replace-root-volume-task'|'reserved-instances'|'route-table'|'security-group'|'security-group-rule'|'snapshot'|'spot-fleet-request'|'spot-instances-request'|'subnet'|'subnet-cidr-reservation'|'traffic-mirror-filter'|'traffic-mirror-session'|'traffic-mirror-target'|'transit-gateway'|'transit-gateway-attachment'|'transit-gateway-connect-peer'|'transit-gateway-multicast-domain'|'transit-gateway-route-table'|'volume'|'vpc'|'vpc-endpoint'|'vpc-endpoint-service'|'vpc-peering-connection'|'vpn-connection'|'vpn-gateway'|'vpc-flow-log',
                #         'Tags': [
                #             {
                #                 'Key': 'string',
                #                 'Value': 'string'
                #             },
                #         ]
                #     },
                #],
                # 'ElasticGpuSpecifications': [
                #     {
                #         'Type': 'string'
                #     },
                # ],
                # 'ElasticInferenceAccelerators': [
                #     {
                #         'Type': 'string',
                #         'Count': 123
                #     },
                # ],
                # 'SecurityGroups': [
                #     'string',
                # ],
            #     'InstanceMarketOptions': {
            #         'MarketType': 'spot',
            #         'SpotOptions': {
            #             'MaxPrice': 'string',
            #             'SpotInstanceType': 'one-time'|'persistent',
            #             'BlockDurationMinutes': 123,
            #             'ValidUntil': datetime(2015, 1, 1),
            #             'InstanceInterruptionBehavior': 'hibernate'|'stop'|'terminate'
            #         }
            #     },
            #     'CreditSpecification': {
            #         'CpuCredits': 'string'
            #     },
            #     'CpuOptions': {
            #         'CoreCount': 123,
            #         'ThreadsPerCore': 123
            #     },
            #     'CapacityReservationSpecification': {
            #         'CapacityReservationPreference': 'open'|'none',
            #         'CapacityReservationTarget': {
            #             'CapacityReservationId': 'string',
            #             'CapacityReservationResourceGroupArn': 'string'
            #         }
            #     },
            #     'LicenseSpecifications': [
            #         {
            #             'LicenseConfigurationArn': 'string'
            #         },
            #     ],
            #     'HibernationOptions': {
            #         'Configured': True|False
            #     },
            #     'MetadataOptions': {
            #         'HttpTokens': 'optional'|'required',
            #         'HttpPutResponseHopLimit': 123,
            #         'HttpEndpoint': 'disabled'|'enabled',
            #         'HttpProtocolIpv6': 'disabled'|'enabled',
            #         'InstanceMetadataTags': 'disabled'|'enabled'
            #     },
            #     'EnclaveOptions': {
            #         'Enabled': True|False
            #     },
            #     'InstanceRequirements': {
            #         'VCpuCount': {
            #             'Min': 123,
            #             'Max': 123
            #         },
            #         'MemoryMiB': {
            #             'Min': 123,
            #             'Max': 123
            #         },
            #         'CpuManufacturers': [
            #             'intel'|'amd'|'amazon-web-services',
            #         ],
            #         'MemoryGiBPerVCpu': {
            #             'Min': 123.0,
            #             'Max': 123.0
            #         },
            #         'ExcludedInstanceTypes': [
            #             'string',
            #         ],
            #         'InstanceGenerations': [
            #             'current'|'previous',
            #         ],
            #         'SpotMaxPricePercentageOverLowestPrice': 123,
            #         'OnDemandMaxPricePercentageOverLowestPrice': 123,
            #         'BareMetal': 'included'|'required'|'excluded',
            #         'BurstablePerformance': 'included'|'required'|'excluded',
            #         'RequireHibernateSupport': True|False,
            #         'NetworkInterfaceCount': {
            #             'Min': 123,
            #             'Max': 123
            #         },
            #         'LocalStorage': 'included'|'required'|'excluded',
            #         'LocalStorageTypes': [
            #             'hdd'|'ssd',
            #         ],
            #         'TotalLocalStorageGB': {
            #             'Min': 123.0,
            #             'Max': 123.0
            #         },
            #         'BaselineEbsBandwidthMbps': {
            #             'Min': 123,
            #             'Max': 123
            #         },
            #         'AcceleratorTypes': [
            #             'gpu'|'fpga'|'inference',
            #         ],
            #         'AcceleratorCount': {
            #             'Min': 123,
            #             'Max': 123
            #         },
            #         'AcceleratorManufacturers': [
            #             'nvidia'|'amd'|'amazon-web-services'|'xilinx',
            #         ],
            #         'AcceleratorNames': [
            #             'a100'|'v100'|'k80'|'t4'|'m60'|'radeon-pro-v520'|'vu9p',
            #         ],
            #         'AcceleratorTotalMemoryMiB': {
            #             'Min': 123,
            #             'Max': 123
            #         }
            #     },
            #     'PrivateDnsNameOptions': {
            #         'HostnameType': 'ip-name'|'resource-name',
            #         'EnableResourceNameDnsARecord': True|False,
            #         'EnableResourceNameDnsAAAARecord': True|False
            #     }
            # },
            # TagSpecifications=[
            #     {
            #         'ResourceType': 'capacity-reservation'|'client-vpn-endpoint'|'customer-gateway'|'carrier-gateway'|'dedicated-host'|'dhcp-options'|'egress-only-internet-gateway'|'elastic-ip'|'elastic-gpu'|'export-image-task'|'export-instance-task'|'fleet'|'fpga-image'|'host-reservation'|'image'|'import-image-task'|'import-snapshot-task'|'instance'|'instance-event-window'|'internet-gateway'|'ipam'|'ipam-pool'|'ipam-scope'|'ipv4pool-ec2'|'ipv6pool-ec2'|'key-pair'|'launch-template'|'local-gateway'|'local-gateway-route-table'|'local-gateway-virtual-interface'|'local-gateway-virtual-interface-group'|'local-gateway-route-table-vpc-association'|'local-gateway-route-table-virtual-interface-group-association'|'natgateway'|'network-acl'|'network-interface'|'network-insights-analysis'|'network-insights-path'|'network-insights-access-scope'|'network-insights-access-scope-analysis'|'placement-group'|'prefix-list'|'replace-root-volume-task'|'reserved-instances'|'route-table'|'security-group'|'security-group-rule'|'snapshot'|'spot-fleet-request'|'spot-instances-request'|'subnet'|'subnet-cidr-reservation'|'traffic-mirror-filter'|'traffic-mirror-session'|'traffic-mirror-target'|'transit-gateway'|'transit-gateway-attachment'|'transit-gateway-connect-peer'|'transit-gateway-multicast-domain'|'transit-gateway-route-table'|'volume'|'vpc'|'vpc-endpoint'|'vpc-endpoint-service'|'vpc-peering-connection'|'vpn-connection'|'vpn-gateway'|'vpc-flow-log',
            #         'Tags': [
            #             {
            #                 'Key': 'string',
            #                 'Value': 'string'
            #             },
            #         ]
            #     },
            # ]
            }
        )
        
        response2 = ec2.modify_launch_template(
            DryRun=False,
            LaunchTemplateId=i['ec2LaunchTemplateID'],
            DefaultVersion=str(response['LaunchTemplateVersion']['VersionNumber'])
        )
        
        
    return json.dumps(response, default=str)