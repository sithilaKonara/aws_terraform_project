import json
import os
import boto3
import time
import uuid
import csv
from datetime import datetime, timedelta
import requests

# S3 bucket which contains the csv file with change ticket details.
BUCKET = os.environ['S3_BUCKET']

# File name
KEY = os.environ['FILE_NAME']


def lambda_handler(event, context):
    s3_client = boto3.resource('s3')
    download_path = '/tmp/{}'.format(uuid.uuid4())
    change_tickets = {}
    try:
        s3_client.Bucket(BUCKET).download_file(KEY, download_path)
        input_items = open(download_path).read()
        with open(download_path, 'r', newline='', encoding='utf-8-sig') as inFile:
            fileReader = csv.reader(inFile)
            line_count = 0
            change_tickets = {}
            for row in fileReader:
                if line_count == 0:
                    line_count += 1
                    index = 0
                    for item in row:
                        if index == 0:
                            index = + 1
                            continue
                        capp_required = item
                    continue
                ticket = row[1]
                change_tickets[row[0]] = ticket
            print('Change Tickets: ', change_tickets)

        ssm_client = boto3.client('ssm')
        cycles = ["Dev", "QA", "Prod"]
        for cycle in cycles:
            for num in range(0, 28):
                if num < 9:
                    pchNm = str(cycle) + "-" + "0" + str((num + 1))
                else:
                    pchNm = str(cycle) + "-" + str((num + 1))
                # ((num > 0 and num < 4) or num > 16):
                if (cycle == 'Dev' or cycle == 'QA') and (num < 4 or num > 16):
                    continue
                elif cycle == 'Prod' and ((num > 0 and num < 4) or (num > 16 and num < 24) or (num > 24)):
                    continue

                time.sleep(0.5)
                windows = ssm_client.describe_maintenance_windows(
                    Filters=[
                        {
                            'Key': 'Name',
                            'Values': [
                                pchNm
                            ]
                        }
                    ]
                )
                for window in windows['WindowIdentities']:
                    if window.get('NextExecutionTime'):
                        # 13.30
                        next_execution_time = window['NextExecutionTime']

                        date_time_obj = datetime.strptime(
                            next_execution_time, '%Y-%m-%dT%H:%MZ')       # 2023-01-11 08:55:00
                        current_time = datetime.now()   # 13.15
                        compare_time = current_time + \
                            timedelta(minutes=30)    # 13.45

                        if cycle == 'Dev' or cycle == 'QA':
                            change_ticket = change_tickets[cycle]
                            if capp_required == 'TRUE':
                                capp_change = change_tickets['CAPP-' + cycle]
                                change_ticket = change_ticket + ' / ' + capp_change

                        if cycle == 'Prod':
                            change_ticket = change_tickets[pchNm]
                            if capp_required == 'TRUE':
                                capp_change = change_tickets['CAPP-' + pchNm]
                                change_ticket = change_ticket + ' / ' + capp_change

                        if date_time_obj < compare_time:
                            print('Cycle name: ', pchNm)
                            print('Next execution time: ', date_time_obj)
                            print('Notifications required for this window')
                            headers = {'Content-Type': 'application/json'}
                            start_time = date_time_obj
                            end_time = start_time + timedelta(hours=5)
                            start_time = str(start_time)
                            end_time = str(end_time)
                            data = {
                                "@type": "MessageCard",
                                "@context": "http://schema.org/extensions",
                                "themeColor": "252423",
                                "summary": "Patching will be starting in 30 minutes",
                                "sections": [{
                                    "activityTitle": pchNm + " Patching Cycle Starting in 30 Minutes - " + change_ticket,
                                    "activitySubtitle": "",
                                    "activityImage": "data:image/png;base64,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",
                                    "facts": [{
                                        "name": "Start Time",
                                        "value": start_time + " GMT"
                                    }, {
                                        "name": "End Time",
                                        "value": end_time + " GMT"
                                    }],
                                    "markdown": "true"
                                }],
                                "potentialAction": [{
                                    "@type": "OpenUri",
                                    "name": "Server List",
                                    "targets": [
                                            {"os": "default", "uri": "https://url.sharepoint.com/:x:/s/TechOpsPlatformOperationsOSTA/ESKLyrxTe0tMhKaKtB5heuYBm9w3aSILL_dft_BI-PmQ_g?e=2ClkTC"}
                                    ]
                                }]
                            }
                            print(data)

                            # Troubleshooting channel
                            # OSTA_tshoot_URL = 'https://url.webhook.office.com/webhookb2/66be1b07-e1a4-49bb-a1df-4c6ba0a20d40@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/26f3a0050edf4bd0acce9d546a1e11df/65f5db95-e0ec-46cb-a85c-31469c7e4c46'
                            # os-ta
                            osta_url = 'https://url.webhook.office.com/webhookb2/66be1b07-e1a4-49bb-a1df-4c6ba0a20d40@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/6876ef265a9541f896f67145442de0e8/65f5db95-e0ec-46cb-a85c-31469c7e4c46'
                            # ent_ops
                            ent_ops = 'https://url.webhook.office.com/webhookb2/c30f35fa-bf27-413d-bc41-56764f2918a4@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/4629bda837154ef78307b2fd1f50e343/65f5db95-e0ec-46cb-a85c-31469c7e4c46'
                            # operations
                            operations = 'https://url.webhook.office.com/webhookb2/cc506389-356e-4239-a519-cacbf8945c14@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/fd9bb0f37e6b4a178f85edf8b70bc8ef/f384e140-1a47-424c-9d47-f84d3ab0a211'
                            # pod3
                            pod3 = 'https://url.webhook.office.com/webhookb2/71cb1224-3f17-4820-8ef4-efd4d2dae224@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/208feebdf79e4febb928863b95b508fc/f30df147-3030-4006-8251-41ec3b4568f6'
                            # TPI
                            tpi = 'https://url.webhook.office.com/webhookb2/989b61ec-f737-46ae-ad57-77f0bca29ce3@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/fc72809265c44dc2aa5b3e284a0da3a3/f30df147-3030-4006-8251-41ec3b4568f6'
                            # 3PL
                            _3pl = 'https://url.webhook.office.com/webhookb2/4618d39c-6857-45fd-b56f-fbcff94e1381@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/0b6b0cf2649c4e5cba608757782a3bc2/f30df147-3030-4006-8251-41ec3b4568f6'
                            # MX
                            mx = 'https://url.webhook.office.com/webhookb2/a0c9694d-e12a-4617-8a24-e4add0c64c23@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/868c40db595b4852aeb401a03e53faa1/f30df147-3030-4006-8251-41ec3b4568f6'
                            # pod2
                            #pod2 = 'https://url.webhook.office.com/webhookb2/71cb1224-3f17-4820-8ef4-efd4d2dae224@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/c212d3b42a2a4ef2a9a01b3a6335ba43/21ad8408-a5e3-48ba-824e-084fcd52ff55'
                            pod2 = 'https://url.webhook.office.com/webhookb2/9cdc1525-9e2a-4f31-ba32-e6cf6efd7bc8@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/58542cdba9454932a85feb1df8c56061/2ca459a2-ebed-4ddd-9164-d07c7f1132ec'
                            # pod1
                            pod1 = 'https://url.webhook.office.com/webhookb2/71cb1224-3f17-4820-8ef4-efd4d2dae224@8cc434d7-97d0-47d3-b5c5-14fe0e33e34b/IncomingWebhook/f9d79d8521764e3182ce9ac5dfc2e25f/8e4d7e39-7d07-47cb-af80-a8d19d39702f'
                            response = requests.post(
                                osta_url, headers=headers, data=json.dumps(data))
                            response = requests.post(
                                ent_ops, headers=headers, data=json.dumps(data))
                            response = requests.post(
                                operations, headers=headers, data=json.dumps(data))
                            # response = requests.post(OSTA_tshoot_URL, headers=headers, data=json.dumps(data))

                            if capp_required == 'TRUE':
                                response = requests.post(
                                    pod3, headers=headers, data=json.dumps(data))
                                response = requests.post(
                                    tpi, headers=headers, data=json.dumps(data))
                                response = requests.post(
                                    _3pl, headers=headers, data=json.dumps(data))
                                response = requests.post(
                                    mx, headers=headers, data=json.dumps(data))
                                response = requests.post(
                                    pod2, headers=headers, data=json.dumps(data))
                                response = requests.post(
                                    pod1, headers=headers, data=json.dumps(data))
                                # response = requests.post(OSTA_tshoot_URL, headers=headers, data=json.dumps(data))  #### > remove this line, once testing done < ####
                            print('Response: ', response)
                        else:
                            print('Cycle ', pchNm,
                                  'is not in notification period')
                    else:
                        print(
                            'Cycle ', pchNm, 'is not enabled or next execution time is not available')

    except Exception as e:
        print('Exception found: ', e)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
