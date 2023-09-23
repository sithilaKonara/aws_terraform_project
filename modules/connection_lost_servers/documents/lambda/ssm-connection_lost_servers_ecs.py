import json
import boto3
import os


# Variables
ASSUME_EXECUTION_ROLE = os.environ['ASSUME_EXECUTION_ROLE']
TASK_DEFINITION = os.environ['TASK_DEFINITION']
PRIVATE_SUBNETS = os.environ['PRIVATE_SUBNETS']
ACCOUNT_IDS = os.environ['ACCOUNT_IDS']
AWS_REGIONS = os.environ['AWS_REGIONS']


def lambda_handler(event, context):
    client = boto3.client('ecs')
    response = client.run_task(
        cluster='SSM',
        launchType='FARGATE',
        taskDefinition=TASK_DEFINITION,
        count=1,
        platformVersion='LATEST',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': [PRIVATE_SUBNETS],
                'assignPublicIp': 'DISABLED'
            }
        },
        overrides={
            'containerOverrides': [
                {
                    'name': 'nfscheck',
                    'environment': [
                        {
                            'name': 'ASSUME_EXECUTION_ROLE',
                            'value': ASSUME_EXECUTION_ROLE
                        },
                        {
                            'name': 'ACCOUNT_IDS',
                            'value': ACCOUNT_IDS
                        },
                        {
                            'name': 'AWS_REGIONS',
                            'value': AWS_REGIONS
                        }
                    ],
                },
            ]
        })

    print('response', response)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
