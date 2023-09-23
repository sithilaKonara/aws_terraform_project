import json
import boto3
import os

# athena constant
DATABASE_NAME = os.environ['DATABASE_NAME']
# athena output s3 bucket
S3_OUTPUT_BUCKET = os.environ['OUTPUT_ATHENA_S3_BUCKET']
# SNS ARN for notifications
SNS_ARN = os.environ['SNS_ARN']
# SSM target execution Role
ASSUME_EXECUTION_ROLE = os.environ['ASSUME_EXECUTION_ROLE']
# VPC private subnets
PRIVATE_SUBNETS = os.environ['PRIVATE_SUBNETS']
# ECS task definition
TASK_DEFINITION = os.environ['TASK_DEFINITION']
# ECS task name
TASK_NAME = os.environ['TASK_NAME']


def lambda_handler(event, context):
    for record in event['Records']:
        # Assign some variables that make it easier to work with the data in the event record.
        BUCKET_NAME = record['s3']['bucket']['name']
        FILE_NAME = record['s3']['object']['key']

    client = boto3.client('ecs')
    response = client.run_task(
        cluster='SSM',
        launchType='FARGATE',
        taskDefinition=TASK_DEFINITION,
        count=1,
        platformVersion='LATEST',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': PRIVATE_SUBNETS.split(','),
                'assignPublicIp': 'DISABLED'
            }
        },
        overrides={
            'containerOverrides': [
                {
                    'name': TASK_NAME,
                    'environment': [
                        {
                            'name': 'DATABASE_NAME',
                            'value': DATABASE_NAME
                        },
                        {
                            'name': 'OUTPUT_ATHENA_S3_BUCKET',
                            'value': S3_OUTPUT_BUCKET
                        },
                        {
                            'name': 'SNS_ARN',
                            'value': SNS_ARN
                        },
                        {
                            'name': 'ASSUME_EXECUTION_ROLE',
                            'value': ASSUME_EXECUTION_ROLE
                        },
                        {
                            'name': 'BUCKET_NAME',
                            'value': BUCKET_NAME
                        },
                        {
                            'name': 'FILE_NAME',
                            'value': FILE_NAME
                        },
                    ],
                },
            ]
        })

    print('response', response)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
