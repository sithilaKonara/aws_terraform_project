import json
import boto3
import os


SNS_ARN = os.environ['SNS_ARN']                                     # SNS ARN for notifications
ASSUME_EXECUTION_ROLE = os.environ['ASSUME_EXECUTION_ROLE']         # SSM target execution Role
PATCH_DEPLOYMENT_TRACKER = os.environ['PATCH_DEPLOYMENT_TRACKER']   # SSM patch deplyment tracker DB
# ECS_CLUSTER_PROPERTIES = os.environ['ECS_CLUSTER_PROPERTIES']     #### > What is the purpose of this < ####
# 'subnet-0785fd1c72b989729,subnet-0e73f175a37f03cd5'
PRIVATE_SUBNETS = os.environ['PRIVATE_SUBNETS']                     # VPC private subnets
TASK_DEFINITION = os.environ['TASK_DEFINITION']                     # ECS task definition
TASK_NAME = os.environ['TASK_NAME']

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table_name = dynamodb.Table(PATCH_DEPLOYMENT_TRACKER)
    #### > get the patching cycle list from a vairable < ####
    # patch_cycles = ["Dev-05","Dev-06","Dev-07","Dev-08","Dev-09","Dev-10","Dev-11","Dev-12","Dev-13","Dev-14","Dev-15","Dev-16","Dev-17","QA-05","QA-06","QA-07","QA-08","QA-09","QA-10","QA-11","QA-12","QA-13","QA-14","QA-15","QA-16","QA-17","Prod-01","Prod-05","Prod-06","Prod-07","Prod-08","Prod-09","Prod-10","Prod-11","Prod-12","Prod-13","Prod-14","Prod-15","Prod-16","Prod-17","Prod-25"]
    #### > Add Dev-01 for testing < ####
    patch_cycles = ["Dev-01"]
    for cycle in patch_cycles:
        response = table_name.get_item(Key={'Patch Cycle': cycle})
        item = response['Item']
        item['Patch Status'] = 'Pending'
        update_db = table_name.put_item(Item=item)
        
    client = boto3.client('ecs')
    response = client.run_task(
        cluster='SSM',
        launchType = 'FARGATE',
        taskDefinition=TASK_DEFINITION,
        count = 1,
        platformVersion='LATEST',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': PRIVATE_SUBNETS.split(','), #### > The subnet ID 'subnet-0785fd1c72b989729,subnet-0e73f175a37f03cd5' does not exist < ####
                'assignPublicIp': 'DISABLED'
            }
		},
		overrides={
            'containerOverrides': [
                {
                    # 'name': 'tags_reset',
                    'name': TASK_NAME, 
				    'environment': [
				        {
                            'name': 'SNS_ARN',
                            'value': SNS_ARN
                        },
				        {
                            'name': 'ASSUME_EXECUTION_ROLE',
                            'value': ASSUME_EXECUTION_ROLE
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