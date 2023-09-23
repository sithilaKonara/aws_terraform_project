import json
import boto3
import os


# Assume execution role
ASSUME_EXECUTION_ROLE = os.environ['ASSUME_EXECUTION_ROLE']
TASK_DEFINITION = os.environ['TASK_DEFINITION']  # ECS task definition
PRIVATE_SUBNETS = os.environ['PRIVATE_SUBNETS']  # VPC private subnets
TASK_NAME = os.environ['TASK_NAME']
DATABASE = os.environ['DATABASE']


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
                            'name': 'DATABASE',
                            'value': DATABASE
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
