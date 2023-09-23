import json
import boto3
import os

# Assume execution role
ASSUME_EXECUTION_ROLE = os.environ['ASSUME_EXECUTION_ROLE']

# Email tags
EMAIL_TAG_1 = os.environ['EMAIL_TAG_1']

EMAIL_TAG_2 = os.environ['EMAIL_TAG_2']

EMAIL_TAG_3 = os.environ['EMAIL_TAG_3']

EMAIL_TAG_4 = os.environ['EMAIL_TAG_4']

EMAIL_TAG_5 = os.environ['EMAIL_TAG_5']

EMAIL_TAG_6 = os.environ['EMAIL_TAG_6']

EMAIL_TAG_7 = os.environ['EMAIL_TAG_7']

EMAIL_TAG_8 = os.environ['EMAIL_TAG_8']

EMAIL_TAG_9 = os.environ['EMAIL_TAG_9']

EMAIL_TAG_10 = os.environ['EMAIL_TAG_10']

HOST_NAME_TAG = os.environ['HOST_NAME_TAG']

# athena constant
DATABASE = os.environ['DATABASE']
DATABASE_PDT = os.environ['DATABASE_PDT']
DATABASE_MPF = os.environ['DATABASE_MPF']

# athena output s3 bucket
S3_OUTPUT_BUCKET = os.environ['S3_OUTPUT_BUCKET']


# This address must be verified with Amazon SES.
SENDER = os.environ['SENDER']

# AWS Region you're using for Amazon SES.
AWS_SES_REGION = os.environ['AWS_SES_REGION']
S3_BUCKET = os.environ['S3_BUCKET']
FILE_NAME = os.environ['FILE_NAME']
TASK_DEFINITION = os.environ['TASK_DEFINITION']
PRIVATE_SUBNETS = os.environ['PRIVATE_SUBNETS']
TASK_NAME = os.environ['TASK_NAME']


def lambda_handler(event, context):
    EVENT = json.dumps(event)
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
                            'name': 'ASSUME_EXECUTION_ROLE',
                            'value': ASSUME_EXECUTION_ROLE
                        },
                        {
                            'name': 'SENDER',
                            'value': SENDER
                        },
                        {
                            'name': 'AWS_SES_REGION',
                            'value': AWS_SES_REGION
                        },
                        {
                            'name': 'HOST_NAME_TAG',
                            'value': HOST_NAME_TAG
                        },
                        {
                            'name': 'EMAIL_TAG_1',
                            'value': EMAIL_TAG_1
                        },
                        {
                            'name': 'EMAIL_TAG_2',
                            'value': EMAIL_TAG_2
                        },
                        {
                            'name': 'EMAIL_TAG_3',
                            'value': EMAIL_TAG_3
                        },
                        {
                            'name': 'EMAIL_TAG_4',
                            'value': EMAIL_TAG_4
                        },
                        {
                            'name': 'EMAIL_TAG_5',
                            'value': EMAIL_TAG_5
                        },
                        {
                            'name': 'EMAIL_TAG_6',
                            'value': EMAIL_TAG_6
                        },
                        {
                            'name': 'EMAIL_TAG_7',
                            'value': EMAIL_TAG_7
                        },
                        {
                            'name': 'EMAIL_TAG_8',
                            'value': EMAIL_TAG_8
                        },
                        {
                            'name': 'EMAIL_TAG_9',
                            'value': EMAIL_TAG_9
                        },
                        {
                            'name': 'EMAIL_TAG_10',
                            'value': EMAIL_TAG_10
                        },
                        {
                            'name': 'EVENT',
                            'value': EVENT
                        },
                        {
                            'name': 'S3_BUCKET',
                            'value': S3_BUCKET
                        },
                        {
                            'name': 'FILE_NAME',
                            'value': FILE_NAME
                        },
                        {
                            'name': 'DATABASE',
                            'value': DATABASE
                        },
                        {
                            'name': 'DATABASE_PDT',
                            'value': DATABASE_PDT
                        },
                        {
                            'name': 'DATABASE_MPF',
                            'value': DATABASE_MPF
                        },
                        {
                            'name': 'S3_OUTPUT_BUCKET',
                            'value': S3_OUTPUT_BUCKET
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
