import json
import boto3
from datetime import datetime, timedelta
import time
from botocore.exceptions import ClientError
import os

last_month_last_day = datetime.today().replace(day=1) - timedelta(1)
last_month = last_month_last_day.strftime("%B").lower()
year = last_month_last_day.strftime("%Y")

REGION = os.environ['REGION']
TABLE = os.environ['TABLE']

dynamodb = boto3.resource('dynamodb', region_name=REGION)
d_table = dynamodb.Table(TABLE)
instance_list = []
dev_list, qa_list, prod_list = [], [], []


class SSM_Instance:
    patching_month = None
    instance_id = None
    computer_name = None
    l1_support_group = None
    patching_cycle = None
    patching_status = None
    patching_required = None


def lambda_handler(event, context):

    response = d_table.scan()

    if response.get('Items'):
        #print('Response', response)
        for item in response['Items']:
            instance = SSM_Instance()
            instance.instance_id = item['InstanceId']
            instance.patching_month = item.get('month', "None")
            instance.computer_name = item.get('fqdn', "None")
            instance.l1_support_group = item.get('server_l1_support', "None")
            instance.patching_cycle = item.get('os_patch_cycle', "None")
            instance.patching_status = item.get('patching_status', "None")
            instance.patching_required = item.get('patching_required', "None")
            #print( str(instance.patching_month)+" "+ str(instance.instance_id) + " " + str(instance.computer_name) + " " + str(instance.l1_support_group) + " " + str(instance.patching_cycle), " " + str(instance.patching_status))
            instance_list.append(instance)

        if response.get('LastEvaluatedKey'):
            next_last_e_key = response['LastEvaluatedKey']

            while True:
                #print('ExclusiveStartKey' , next_last_e_key)
                response01 = d_table.scan(ExclusiveStartKey=next_last_e_key)
                #print('Response01', response01)

                for item in response01['Items']:
                    instance = SSM_Instance()
                    instance.instance_id = item['InstanceId']
                    instance.patching_month = item.get('month', "None")
                    instance.computer_name = item.get('fqdn', "None")
                    instance.l1_support_group = item.get(
                        'server_l1_support', "None")
                    instance.patching_cycle = item.get(
                        'os_patch_cycle', "None")
                    instance.patching_status = item.get(
                        'patching_status', "None")
                    instance.patching_required = item.get(
                        'patching_required', "None")
                    #print( str(instance.patching_month)+" "+ str(instance.instance_id) + " " + str(instance.computer_name) + " " + str(instance.l1_support_group) + " " + str(instance.patching_cycle), " " + str(instance.patching_status))

                    instance_list.append(instance)
                if not response01.get('LastEvaluatedKey'):
                    print("********DB read complete**********")
                    break
                next_last_e_key = response01['LastEvaluatedKey']

    dev_list = select_patching_environment(instance_list, 'Dev')
    qa_list = select_patching_environment(instance_list, 'QA')
    prod_list = select_patching_environment(instance_list, 'Prod')

    cli = []
    cli = send_email(dev_list, 'TO XC Platform Operations OS',
                     'email@abccompany.com', "Dev")
    cli = send_email(cli, "TO XC HED SRE POD 1",
                     'email@grp.abccompany.com', "Dev")
    cli = send_email(cli, "TO XC HED SRE POD 2",
                     'email@grp.abccompany.com', "Dev")
    cli = send_email(cli, "TO XC HED SRE POD 3",
                     'email@grp.abccompany.com', "Dev")
    cli = send_email(cli, "	PT XC AD Support",
                     'email@abccompany.com', "Dev")
    cli = send_email(
        cli, "Other", 'email@abccompany.com', "Dev")

    cli = send_email(qa_list, 'TO XC Platform Operations OS',
                     'email@abccompany.com', "QA")
    cli = send_email(cli, "TO XC HED SRE POD 1",
                     'email@grp.abccompany.com', "QA")
    cli = send_email(cli, "TO XC HED SRE POD 2",
                     'email@grp.abccompany.com', "QA")
    cli = send_email(cli, "TO XC HED SRE POD 3",
                     'email@grp.abccompany.com', "QA")
    cli = send_email(cli, "	PT XC AD Support",
                     'email@abccompany.com', "QA")
    cli = send_email(
        cli, "Other", 'email@abccompany.com', "QA")

    cli = send_email(prod_list, 'TO XC Platform Operations OS',
                     'email@abccompany.com', "Prod")
    cli = send_email(cli, "TO XC HED SRE POD 1",
                     'email@grp.abccompany.com', "Prod")
    cli = send_email(cli, "TO XC HED SRE POD 2",
                     'email@grp.abccompany.com', "Prod")
    cli = send_email(cli, "TO XC HED SRE POD 3",
                     'email@grp.abccompany.com', "Prod")
    cli = send_email(cli, "	PT XC AD Support",
                     'email@abccompany.com', "Prod")
    cli = send_email(
        cli, "Other", 'email@abccompany.com', "Prod")

# ==============================================================================================================
# ==============================================================================================================


def select_patching_environment(list, p_cycle):
    t = []
    for i in list:
        #print("Before",i.computer_name, i.patching_month,i.patching_required,i.patching_cycle,i.patching_status)
        if (str(i.patching_month).lower() == last_month.lower() and str(i.patching_required).lower() == 'true' and p_cycle in i.patching_cycle) and (str(i.patching_status).lower() == 'failed' or str(i.patching_status).lower() == 'pending'):
            # print("After",i.computer_name,i.patching_month,i.patching_required,i.patching_cycle,i.patching_status)
            t.append(i)
    return t


def send_email(list, l1Group, email, p_cycle):

    sendEmail = False
    BODY_HTML = """<html>
                    <head></head>
                    <body>
                    <h1>Amazon SSM Patching failure summary</h1>
                    <div><table>
                    <thead><tr><td><b>Instance ID</b></td><td><b>Computer Name</b></td><td><b>Patching Cycle</b></td><td><b>L1 Support Group</b></td></tr></thead>
                    <tbody>"""

    t = 0
    tl = []
    for i in list:
        if i.l1_support_group.lower() == l1Group.lower():
            sendEmail = True
            BODY_HTML = BODY_HTML + "<tr><td> "+str(i.instance_id)+"</td><td>"+str(
                i.computer_name)+"</td><td>"+str(i.patching_cycle)+"</td><td>"+str(i.l1_support_group)+"</td></tr>"
        elif l1Group.lower() == 'other':
            sendEmail = True
            BODY_HTML = BODY_HTML + "<tr><td> "+str(i.instance_id)+"</td><td>"+str(
                i.computer_name)+"</td><td>"+str(i.patching_cycle)+"</td><td>"+str(i.l1_support_group)+"</td></tr>"
        else:
            tl.append(i)

    if sendEmail:
        BODY_HTML = BODY_HTML + "</tbody></table></div></body></html>"
        SENDER = "email@abccompany.com"
        RECIPIENT = email
        AWS_REGION = REGION
        SUBJECT = "Amazon SSM Patching failure summary - " + p_cycle + " cycle - " + \
            str(last_month.capitalize()) + " " + \
            str(year) + " - " + l1Group + " - Managed"
        BODY_TEXT = ("Amazon SSM Patching failure summery.")
        CHARSET = "UTF-8"
        client = boto3.client('ses', region_name=AWS_REGION)

    # Try to send the email.
        try:
            # Provide the contents of the email.
            response = client.send_email(
                Destination={
                    'ToAddresses': [
                        RECIPIENT,
                    ],
                    'CcAddresses': [
                        'email@abccompany.com',
                    ]
                },
                Message={
                    'Body': {
                        'Html': {
                            'Charset': CHARSET,
                            'Data': BODY_HTML,
                        },
                        'Text': {
                            'Charset': CHARSET,
                            'Data': BODY_TEXT,
                        },
                    },
                    'Subject': {
                        'Charset': CHARSET,
                        'Data': SUBJECT,
                    },
                },
                Source=SENDER,
                # ConfigurationSetName='ssm_config_set',
            )
    # Display an error if something goes wrong.
        except ClientError as e:
            print(e.response['Error']['Message'])
        else:
            print("Email sent! Message ID:"),
            print(response['MessageId'])

    return tl
