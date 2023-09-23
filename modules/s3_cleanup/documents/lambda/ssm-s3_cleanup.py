import boto3
import uuid
import csv
import time
import json
import sys
import re
import os
from collections import defaultdict

# Resource sync s3 bucket
S3_BUCKET = os.environ['S3_BUCKET']

# athena constant
DATABASE = os.environ['DATABASE_NAME']

# athena output s3 bucket
S3_OUTPUT_BUCKET = os.environ['S3_OUTPUT_BUCKET']

SNS_ARN = os.environ['SNS_ARN']

# number of retries to fetch result from athena query
RETRY_COUNT = 10

MANAGED_INSTANCE_REGEX = re.compile("mi-[0-9a-f]{17}")

# SSM target execution Role
ASSUME_EXECUTION_ROLE = os.environ['ASSUME_EXECUTION_ROLE']


def lambda_handler(event, context):

    query = "SELECT computername, resourceid, region, accountid FROM %s.aws_instanceinformation where instancestatus = 'Terminated';" % (
        DATABASE)
    print('Query: ', query)

    athena_client = boto3.client('athena')

    response = athena_client.start_query_execution(
        QueryString=query,
        QueryExecutionContext={
            'Database': DATABASE
        },
        ResultConfiguration={
            'OutputLocation': "s3://{}/{}".format(S3_OUTPUT_BUCKET, "Output/tags/Athena-Output")
        }
    )

    query_execution_id = response['QueryExecutionId']

    wait_for_query_to_complete(query_execution_id, athena_client)

    athena_response = athena_client.get_query_results(
        QueryExecutionId=query_execution_id)
    # print('Athena Response: ', athena_response)
    process(athena_response)
    if athena_response.get('NextToken'):
        next_token = athena_response['NextToken']
        while True:
            result = athena_client.get_query_results(
                QueryExecutionId=query_execution_id, NextToken=next_token)
            process(result)
            if not athena_response.get('NextToken'):
                break
            next_token = result.get('NextToken')

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }


def s3_delete(instance_info):
    dir_list = ["AWS:ComplianceItem", "AWS:ComplianceSummary", "AWS:InstanceDetailedInformation", "AWS:InstanceInformation", "AWS:Network",
                "AWS:PatchSummary", "AWS:Service", "AWS:Tag", "AWS:WindowsRole", "AWS:WindowsUpdate", "AWS:Application", "AWS:AWSComponent", "AWS:AWSComponent"]
    instance_id = instance_info[1]['VarCharValue']
    instance_region_id = instance_info[2]['VarCharValue']
    instance_account_id = instance_info[3]['VarCharValue']
    client = boto3.client('s3')

    for key in dir_list:
        keys = {}
        keys['Key'] = key + '/' + 'accountid=' + str(instance_account_id) + '/' + 'region=' + \
            instance_region_id + '/' + 'resourcetype=ManagedInstanceInventory' + \
            '/' + instance_id + '.json'

        response = client.delete_objects(
            Bucket=S3_BUCKET,
            Delete={
                'Objects': [
                    keys
                ]
            }
        )
        # print(response)


def wait_for_query_to_complete(query_execution_id: str, client):
    """ This method would do the wait for athena query to finish the execution
    Parameters:
    query_execution_id (string):Execution Id of the query
    client: Athena client
   """
    for i in range(1, 1 + RETRY_COUNT):
        # get query execution
        query_status = client.get_query_execution(
            QueryExecutionId=query_execution_id)

        query_execution_status = query_status['QueryExecution']['Status']['State']
        if query_execution_status == 'SUCCEEDED':
            # print("Record found:" + query_execution_status)
            break

        if query_execution_status == 'FAILED':
            raise Exception("Athena Query STATUS:" + query_execution_status)
        else:
            time.sleep(i)
    else:
        client.stop_query_execution(QueryExecutionId=query_execution_id)
        raise Exception('Athena Query Time Over')


def process(athena_response):
    hostname = None
    if athena_response.get('ResultSet'):
        result_set = athena_response.get('ResultSet')
        if result_set.get('Rows'):
            if len(athena_response['ResultSet']['Rows']) > 1:
                line_count = 0
                for row in athena_response['ResultSet']['Rows']:
                    if (line_count == 0):
                        line_count += 1
                        continue
                    if row.get('Data'):
                        instance_info = row['Data']
                        if instance_info:
                            if instance_info[0].get('VarCharValue'):
                                hostname = instance_info[0]['VarCharValue']
                                try:
                                    s3_delete(instance_info)
                                    print('Clean-up is Successful for ', hostname)
                                except Exception as e:
                                    print('Exception for instance {}: {}'.format(
                                        hostname, e))
