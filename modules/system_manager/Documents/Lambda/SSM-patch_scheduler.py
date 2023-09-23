import boto3
from datetime import date, timedelta, datetime
from botocore.exceptions import ClientError
import os

REGION = os.environ['REGION']
DATABASE = os.environ['DATABASE']


def lambda_handler(event, context):
    cycle_duration = 5
    cycle_cutoff = 1
    today = date.today()  # - timedelta(days=10)
    print('Today is: ', today)
    month = datetime.today().strftime("%B").lower()
    year = datetime.today().strftime("%Y")
    pkey = month + '-' + year

    dynamodb = boto3.resource('dynamodb')
    # > Take the name as  a variable < ####
    table_name = DATABASE
    table = dynamodb.Table(table_name)

    # Check whether today is patching Tuesday (2nd Tuesday of each month)
    if today.weekday() == 1 and (today.day > 7 and today.day < 15):
        print('Today is second Tuesday')
    else:
        print('Today is not second Tuesday. Script will quit.')
        return

    next_monday = today + timedelta(days=6)
    date_time_str = str(next_monday) + " 05:00:00"
    date_time_dt = datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S')
    # print(date_time_dt)

    client = boto3.client('ssm')
    cycles = ["Dev", "QA", "Prod"]
    for cycle in cycles:
        for num in range(0, 28):
            if num < 9:
                pchNm = str(cycle) + "-" + "0" + str((num + 1))
                # print('Patch Cycle :', pchNm)
            else:
                pchNm = str(cycle) + "-" + str((num + 1))
            if cycle == "Dev":
                pchDttm = date_time_dt + timedelta(hours=(num*6))
            if cycle == "QA":
                pchDt = date_time_dt + timedelta(days=7)
                pchDttm = pchDt + timedelta(hours=(num*6))
            if cycle == "Prod":
                pchDt = date_time_dt + timedelta(days=14)
                pchDttm = pchDt + timedelta(hours=(num*6))
            try:
                windows = client.describe_maintenance_windows(
                    Filters=[
                        {
                            'Key': 'Name',
                            'Values': [
                                pchNm
                            ]
                        }
                    ]
                )
                mwdicts = {}
                for window in windows['WindowIdentities']:
                    window_name = window.get('Name')
                    window_id = window.get('WindowId')
                    schedule = window.get('NextExecutionTime')
                    mwdicts[window_name] = window_id

                response = client.update_maintenance_window(
                    WindowId=mwdicts.get(pchNm),
                    Schedule=fmtDt(pchDttm),
                    ScheduleTimezone='GMT',
                    Duration=cycle_duration,
                    Cutoff=cycle_cutoff,
                    Enabled=True
                )
                db = {}
                db['month-year'] = pkey
                db['patching_cycle'] = pchNm
                db['maintenance_window_GMT'] = str(pchDttm)
                table.put_item(
                    Item=db
                )
                #print('Response :', response)
            except Exception as e:
                if (cycle == 'Dev' or cycle == 'QA') and (num < 4 or num > 16):
                    if num < 4:
                        print(cycle+"-"+"0"+str(num + 1),
                              'is not an active patching cycle')
                    else:
                        print(cycle+"-"+str(num + 1),
                              'is not an active patching cycle')
                elif cycle == 'Prod' and ((num > 0 and num < 4) or (num > 16 and num < 24) or (num > 24)):
                    if num < 4:
                        print(cycle+"-"+"0"+str(num + 1),
                              'is not an active patching cycle')
                    else:
                        print(cycle+"-"+str(num + 1),
                              'is not an active patching cycle')
                else:
                    if num < 9:
                        print(cycle+"-"+"0"+str(num + 1), "Error: ", e)
                    else:
                        print(cycle+"-"+str(num + 1), "Error: ", e)

    SENDER = "email@abccompany.com"
    RECIPIENT = "email@abccompany.com"
    AWS_REGION = REGION
    SUBJECT = "Amazon SSM Patch Scheduling Completed - DR Testing"
    BODY_TEXT = ("Amazon SSM patch scheduling completed.")

    # The HTML body of the email.
    BODY_HTML = """<html>
    <head></head>
    <body>
    <h1>Patch Schedules for this month - DR Testing</h1>
    <div><table>
    <thead><tr><td><b>Cycle Name</b></td><td><b>Next Execution Time</b></td></tr></thead>
    <tbody>"""
    cycles = ["Dev", "QA", "Prod"]
    for cycle in cycles:
        for num in range(0, 28):
            if num < 9:
                pchNm = str(cycle) + "-" + "0" + str((num + 1))
            else:
                pchNm = str(cycle) + "-" + str((num + 1))
            try:
                newres = client.describe_maintenance_windows(
                    Filters=[
                        {
                            'Key': 'Name',
                            'Values': [
                                pchNm
                            ]
                        }
                    ]
                )
                for sch in newres['WindowIdentities']:
                    BODY_HTML = BODY_HTML + "<tr><td> " + \
                        sch.get('Name')+"</td><td>" + \
                        sch.get('NextExecutionTime')+"</td></tr>"
            except:
                print('Something Went Wrong!')

    BODY_HTML = BODY_HTML + "</tbody></table></div></body></html>"

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
        )
    # Display an error if something goes wrong.
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])


def fmtDt(dateObj):
    d = str(dateObj).replace(" ", "T")
    return ("at("+d+")")
