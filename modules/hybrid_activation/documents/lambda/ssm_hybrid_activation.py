import os
import boto3
import datetime

# S3 Bucket
s3 = boto3.client('s3')
bucket = os.environ['S3_BUCKET']
# bucket_dr = os.environ['S3_BUCKET_DR']

# SSM target execution Role
ASSUME_EXECUTION_ROLE = os.environ['ASSUME_EXECUTION_ROLE']

# SNS ARN
SNS_ARN = os.environ['SNS_ARN']

# AWS Account IDs
ACCOUNT_IDS = ["899879149844", "595090145094", "383586206651", "779537016482"]
# ACCOUNT_IDS = os.environ['ACCOUNT_IDS'].split(',')

# AWS Regions
AWS_REGIONS = ["ap-southeast-1", "ap-southeast-2", "ap-northeast-2", "eu-west-2", "sa-east-1", "us-east-1", "us-east-2", "us-west-2"]
# AWS_REGIONS = os.environ["AWS_REGIONS"].split(',')

ORCHESTRATOR_REGION = os.environ["ORCHESTRATOR_REGION"]
ORCHESTRATOR_ACCOUNT = os.environ["ORCHESTRATOR_ACCOUNT"]

# Time calculation
today = datetime.date.today() + datetime.timedelta(30)
expiry_date = (today.strftime('%Y, %m, %d'))

##global_vars###
output = []


def lambda_handler(event, context):
    result = "Account_ID" + "," + "Region_ID" + "," + \
        "Activation_Id" + "," + "Activation_Code"
    output.append(result)
    final = "\n".join(output)

    for instance_account_id in ACCOUNT_IDS:
        if instance_account_id == '779537016482' or instance_account_id == '595090145094':
            AWS_REGIONS_SRE = ["us-east-1", "us-west-2"]
            for instance_region_id in AWS_REGIONS_SRE:
                client = get_client(instance_account_id,
                                    instance_region_id, 'ssm')
                response = client.create_activation(
                    Description='SSM Activation',
                    DefaultInstanceName='Americas',
                    ExpirationDate=expiry_date,
                    IamRole='AWSSSMServiceRole',
                    RegistrationLimit=1000, )

                result = instance_account_id + "," + instance_region_id + "," + response['ActivationId'] + "," + \
                    response['ActivationCode']
                output.append(result)
                final = "\n".join(output)

        else:
            for instance_region_id in AWS_REGIONS:
                if instance_region_id == "ap-southeast-1" or instance_region_id == "ap-southeast-2" or instance_region_id == "ap-northeast-2":
                    Instance_Name = "APAC"
                elif instance_region_id == "eu-west-2":
                    Instance_Name = "EMEA"
                else:
                    Instance_Name = "Americas"
                client = get_client(instance_account_id,
                                    instance_region_id, 'ssm')
                response = client.create_activation(
                    Description='SSM Activation',
                    DefaultInstanceName=Instance_Name,
                    ExpirationDate=expiry_date,
                    IamRole='AWSSSMServiceRole',
                    RegistrationLimit=1000, )

                result = instance_account_id + "," + instance_region_id + "," + response['ActivationId'] + "," + \
                    response['ActivationCode']
                output.append(result)
                final = "\n".join(output)

    print(final)
    s3.put_object(Bucket=bucket, Key="activations/activation.csv", Body=final)
    # s3.put_object(Bucket=bucket_dr, Key="ssm_activation_codes/activation.csv", Body=final, ACL='bucket-owner-full-control')

    sns_client = boto3.client('sns')
    response = sns_client.publish(
        TargetArn=SNS_ARN,
        Message=f'Hybrid Activation code generation completed. Codes can be accessed using ssm-tag-instance-{ORCHESTRATOR_REGION}-{ORCHESTRATOR_ACCOUNT}/activations/activation.csv',
        MessageStructure='html',
        Subject='Hybrid Activation Generated',
    )


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
