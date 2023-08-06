import json
import boto3
import os

def lambda_handler(event, context):

    arn = (event['resources'])
    sourceServerId = (arn[0].split("source-server/",1)[1])

    client = boto3.client('mgn')
    response = client.describe_source_servers(
    filters={
        'isArchived': False,
         'sourceServerIDs': [sourceServerId]
        }
    )
    customer_name = os.environ['customer_name']
    hostname = response['items'][0]['sourceProperties']['identificationHints']['hostname']
    lifecycleState = event['detail']['state']
    
    if lifecycleState == "CUTOVER_LAUNCH_SUCCEEDED":
        status="Cutover lanuch succeeded"
    elif lifecycleState == "CUTOVER_LAUNCH_FAILED":
        status="Cutover lanuch failed"
    elif lifecycleState == "TEST_LAUNCH_SUCCEEDED":
        status="Test launch succeeded"
    elif lifecycleState == "TEST_LAUNCH_FAILED":
        status="Test launch failed"
    elif lifecycleState == "READY_FOR_TEST":
        status="Ready for testing"
    elif lifecycleState == "STALLED":
        status="STALLED"

    client = boto3.client('sns')
    response_sns = client.publish (
      TargetArn = os.environ['sns_arn'] ,
      Message = json.dumps({'default': "Customer : "+customer_name+"\nHostname: "+hostname+"\nStatus: "+status}),
      MessageStructure = 'json'
   )
    return {
        'statusCode': 200,
        'body': response_sns
    }