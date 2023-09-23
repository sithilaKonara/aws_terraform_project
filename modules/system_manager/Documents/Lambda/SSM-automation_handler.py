import json
import boto3
import os
import time

# SSM target execution Role
ASSUME_EXECUTION_ROLE = os.environ['ASSUME_EXECUTION_ROLE']
# SNS
SNS_ARN = os.environ['SNS_ARN']
# Run Command S3 Bucket
S3_TARGET_BUCKET = os.environ['S3_TARGET_BUCKET']
DATABASE = os.environ['DATABASE']


def lambda_handler(event, context):
    print('Event : ', event)
    client = boto3.client('ssm')
    document = event['Document']
    document_version = ''
    document_parameters = ''
    window_id = event['WindowId']
    task_execution_id = event['TaskExecutionId']
    sns_client = boto3.client('sns')

    if document:
        document_name = document['Name']
        document_version = document['Version']
        if document.get('Parameters'):
            document_parameters = document['Parameters']
        target_parameter_name = event['TargetParameterName']

    if event.get('Targets'):
        targets = event['Targets']
        accounts = event['Accounts']
        target_locations = list()
        for account in accounts:
            account_id = account['Account']
            print('Account:', account_id)
            target_location = {}
            regions = list()
            for region_id in account['Regions']:
                key = targets[0]['Key']
                print('Key: ', key)
                try:
                    if key == 'ResourceGroup':
                        print('Value: ', targets[0]['Values'][0])
                        resource_group_client = get_client(
                            account_id, region_id, "resource-groups")

                        instances = resource_group_client.list_group_resources(
                            GroupName=targets[0]['Values'][0]
                        )
                        print('Total instances count: {} found in region: {}'
                              .format(len(instances['ResourceIdentifiers']), region_id))
                        if instances.get('ResourceIdentifiers') and len(instances['ResourceIdentifiers']) > 0:
                            regions.append(region_id)
                    elif key == 'tag-key':
                        print('This feature is currently not supported')
                        response = sns_client.publish(
                            TargetArn=SNS_ARN,
                            Message='Automation failed for WindowId: {}, TaskExecutionId: {}, \
                            Reason: tag-key feature \ not supported'.format(window_id, task_execution_id),
                            MessageStructure='html',
                            Subject='Automation Status',
                        )
                        return
                    else:
                        print('Value: ', targets[0]['Values'][0])
                        ssm_client = get_client(account_id, region_id, "ssm")
                        instances = ssm_client.describe_instance_information(
                            Filters=targets)
                        # print('Instances: ', instances)
                        if instances.get('InstanceInformationList') \
                                and len(instances['InstanceInformationList']) > 0:
                            regions.append(region_id)
                except Exception as e:
                    print('Error: ', e)
                    print('No instances under account {}, region {}'.format(
                        account_id, region_id))
                    continue
            print('Regions:', regions)
            if len(regions) > 0:
                target_location['Accounts'] = [account_id]
                target_location['Regions'] = regions
                target_location['TargetLocationMaxConcurrency'] = event['MaxConcurrency']
                target_location['TargetLocationMaxErrors'] = event['MaxErrors']
                target_location['ExecutionRoleName'] = ASSUME_EXECUTION_ROLE
                target_locations.append(target_location)

        print('Running patching on target_locations {} '.format(target_locations))
        cycle = targets[0]['Values'][0]
        if len(target_locations) > 0:
            client = boto3.client('ssm')
            try:
                response = client.start_automation_execution(
                    DocumentName=document_name,
                    DocumentVersion=document_version,
                    Parameters=document_parameters,
                    TargetParameterName=target_parameter_name,
                    Targets=targets,
                    MaxConcurrency=event['MaxConcurrency'],
                    MaxErrors=event['MaxErrors'],
                    TargetLocations=target_locations
                )

                table = DATABASE
                dynamodb = boto3.resource('dynamodb')
                table_name = dynamodb.Table(table)

                response = table_name.get_item(Key={'Patch Cycle': cycle})
                item = response['Item']
                item['Patch Status'] = 'In progress'
                update_db = table_name.put_item(Item=item)
            except Exception as e:
                print('Automation failed for WindowId: {}, TaskExecutionId: {} with exception {}'.format(
                    window_id, task_execution_id, str(e)))
                response = sns_client.publish(
                    TargetArn=SNS_ARN,
                    Message='Automation failed for WindowId: {}, TaskExecutionId: {}'.format(
                        window_id, task_execution_id),
                    MessageStructure='html',
                    Subject='Automation Status',
                )
                return
            response = sns_client.publish(
                TargetArn=SNS_ARN,
                Message='Automation successfully triggered for WindowId: {}, TaskExecutionId: {}'.format(
                    window_id, task_execution_id),
                MessageStructure='html',
                Subject='Automation Status',
            )
            return
    print('No valid target to run hence stopped')
    response = sns_client.publish(
        TargetArn=SNS_ARN,
        Message='No Targets for requested documents, refer WindowId: {}, TaskExecutionId: {}'.format(
            window_id, task_execution_id),
        MessageStructure='html',
        Subject='Automation Status',
    )

# 899879149844, ap-southeast-1, ssm


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
