import boto3
import uuid
import csv
import time
import json
import sys
import re
import os
from collections import defaultdict

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
    # print('Event: ', event)
    # Get Account ID from lambda function arn in the context
    current_account_id = context.invoked_function_arn.split(":")[4]
    s3_client = boto3.resource('s3')
    sns_client = boto3.client('sns')

    # Iterating records
    non_existing_records = list()
    for record in event['Records']:
        # Assign some variables that make it easier to work with the data in the event record.
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        download_path = '/tmp/{}'.format(uuid.uuid4())
        computer_names = {}
        try:
            s3_client.Bucket(bucket).download_file(key, download_path)
            input_items = open(download_path).read()
            with open(download_path, 'r', newline='', encoding='utf-8-sig') as inFile:
                fileReader = csv.reader(inFile)
                index = 0
                for row in fileReader:
                    item_count = 0
                    for item in row:
                        item_count += 1
                    # print('Item Count: ', item_count)
                    if item_count > 1:
                        sys.exit(
                            "Invalid csv file. Please check your input file")
                    computer_names[row[0].lower()] = index
                    index = + 1
                # print('Computer Names: ', computer_names)

            # Converting list to String for query
            res = "','".join(computer_names.keys())
            query = "SELECT computername, resourceid, region, accountid FROM %s.aws_instanceinformation where lower (computername) in ('%s');" % (
                DATABASE, res)
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
            process(athena_response, computer_names)
            if athena_response.get('NextToken'):
                next_token = athena_response['NextToken']
                while True:
                    result = athena_client.get_query_results(
                        QueryExecutionId=query_execution_id, NextToken=next_token)
                    # print('Result', result)
                    process(result, computer_names)
                    if not athena_response.get('NextToken'):
                        break
                    next_token = result.get('NextToken')

        except Exception as e:
            print('Exception found: ', e)
            response = sns_client.publish(
                TargetArn=SNS_ARN,
                Message='Instance decommission failed with execption: {} '.format(
                    str(e)),
                MessageStructure='html',
                Subject='Decommission Status',
            )

        if len(computer_names) > 0:
            print('Records not found for hostnames: ',
                  list(computer_names.keys()))

        response = sns_client.publish(
            TargetArn=SNS_ARN,
            Message='List of hostnames failed to deregister: {} '.format(
                list(computer_names.keys())),
            MessageStructure='html',
            Subject='Decommission Status',
        )

    return {
        'statusCode': 200,
        'Message': 'Hello from Lambda'
    }


def process(athena_response, computer_names):
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
                                    deregister_managed_instance(instance_info)
                                    computer_names.pop(hostname.lower())
                                    print('Successfully deregistered ', hostname)
                                except Exception as e:
                                    print('Exception for instance {}: {}'.format(
                                        hostname, e))


def deregister_managed_instance(instance_info):
    """ This method would do the deregistration of managed instance
    Parameters:
    instance_id (string):InstanceId of the instance
    client: SSM client for the instance account
   """
    instance_id = instance_info[1]['VarCharValue']
    instance_region_id = instance_info[2]['VarCharValue']
    instance_account_id = instance_info[3]['VarCharValue']

    print('instance_id: ', instance_id)
    if MANAGED_INSTANCE_REGEX.match(instance_id):
        client = get_client(instance_account_id, instance_region_id, 'ssm')
        client.deregister_managed_instance(
            InstanceId=instance_id
        )
    else:
        client = get_client(instance_account_id, instance_region_id, 'ec2')
        client.deregister_managed_instance(
            InstanceId=instance_id
        )


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


def get_client(instance_account_id: str, instance_region_id: str, resource_type: str):
    """ This method would return the SSM client for the instance
        Parameters:
        current_account_id (string):account id of the lambda
        instance_account_id(string):account id of the instance
        instance_region_id(string):region id of the instance

        Returns:
        client: SSM client to update the instance tags
   """
    # Go for STS to assume role for cross account
    sts_connection = boto3.client('sts')
    acct_b = sts_connection.assume_role(
        RoleArn="arn:aws:iam::{}:role/{}".format(
            instance_account_id, ASSUME_EXECUTION_ROLE),
        RoleSessionName="cross_acct_access_for_lambda"
    )
    access_key = acct_b['Credentials']['AccessKeyId']
    secret_key = acct_b['Credentials']['SecretAccessKey']
    session_token = acct_b['Credentials']['SessionToken']
    # create service client using the assumed role credentials, e.g. S3
    return boto3.client(
        resource_type,
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        aws_session_token=session_token,
        region_name=instance_region_id
    )
