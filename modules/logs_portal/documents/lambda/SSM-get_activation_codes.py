import json
import boto3
import csv
import os


def lambda_handler(event, context):

    # Read file from S3 bucket
    print("EVENT:: ", event)
    s3_resource = boto3.resource('s3')
    s3_object = s3_resource.Object(
        os.environ.get('Source'), os.environ.get('File'))
    data = s3_object.get()['Body'].read().decode('utf-8').splitlines()
    lines = csv.reader(data)

    # Check activation code
    for line in lines:
        if event['Val01'] in line and event['Val02'] in line:
            print('Execution was successful')
            # Return data
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'Activation_Id': line[2],
                    'Activation_Code': line[3],
                    'Command': "amazon-ssm-agent -y -register -code " + line[3] + " -id " + line[2] + " -region " + event['Val02']
                })
            }
    print('Execution was failed')
    # Return data
    return {
        'statusCode': 200,
        'body': json.dumps({
            'Error': 'No valied output. Please check account and region again'
        })
    }
