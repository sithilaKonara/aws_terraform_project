import json, boto3, os, re, base64

def lambda_handler(event, context):
    print(event)
    #Get AWS Account Id
    awsAccountId = context.invoked_function_arn.split(':')[4]

    #Read in the environment variables
    dashboardIdList = re.sub(' ','',os.environ['DashboardIdList']).split(',')
    dashboardNameList = os.environ['DashboardNameList'].split(',')
    dashboardRegion = os.environ['DashboardRegion']
    url = os.environ['URL']

    #You might want to embed QuickSight into static or dynamic pages.
    #We will use this API gateway and Lambda combination to simulate both scenarios.
    #In Dynamic mode, we will generate the embed url from QuickSight and send back an HTML page with that url specified.
    #In Static mode, we will first return static HTML. 
    #This page when loaded at client side will make another API gateway call to get the embed url and will then launch the dashboard.
    #We are handling these interactions by using a query string parameter with three possible values - dynamic, static & getUrl.
    mode='dynamic'
    response={} 
    if event['queryStringParameters'] is None:
        mode='dynamic'
    elif 'mode' in event['queryStringParameters'].keys():
        if event['queryStringParameters']['mode'] in ['static','getUrl']:
            mode=event['queryStringParameters']['mode']
        else:
            mode='unsupportedValue'
    else:
        mode='dynamic'
    
    #Set the html file to use based on mode. Generate embed url for dynamic and getUrl modes.
    #Also, If mode is static, get the api gateway url from event. 
    #In a truly static use case (like an html page getting served out of S3, S3+CloudFront),this url be hard coded in the html file
    #Deriving this from event and replacing in html file at run time to avoid having to come back to lambda 
    #to specify the api gateway url while you are building this sample in your environment.
    if mode == 'dynamic':
        htmlFile = open('content/DynamicSample.html', 'r')
        errorFile = open('content/Error.html', 'r')
        response = getQuickSightDashboardUrl(awsAccountId, dashboardIdList, dashboardRegion)
    elif mode == 'static':
        htmlFile = open('content/StaticSample.html', 'r')
        errorFile = open('content/Error.html', 'r')
        if event['headers'] is None or event['requestContext'] is None:
            apiGatewayUrl = 'ApiGatewayUrlIsNotDerivableWhileTestingFromApiGateway'
        else:
            apiGatewayUrl = event['headers']['Host']+event['requestContext']['path']
    elif mode == 'getUrl':
        response = getQuickSightDashboardUrl(awsAccountId, dashboardIdList, dashboardRegion)

    if mode in ['dynamic','static']:
        #Read contents of sample html file
        htmlContent = htmlFile.read()
        #Read logo file in base64 format
        logoFile = open('content/Logo.png','rb')
        logoContent = base64.b64encode(logoFile.read())
    
        #Replace place holders.
        htmlContent = re.sub('<DashboardIdList>', str(dashboardIdList), htmlContent)
        htmlContent = re.sub('<DashboardNameList>', str(dashboardNameList), htmlContent)
        #logoContent when cast to str is in format b'content'.
        #Array notation is used to extract just the content.
        htmlContent = re.sub('<LogoFileBase64>', str(logoContent)[2:-1], htmlContent)
        
        if mode == 'dynamic':
            #Replace Embed URL placeholder.
            api_headers = event['headers']
            if api_headers.get('Referer') == url:
                htmlContent = re.sub('<QSEmbedUrl>', response['EmbedUrl'], htmlContent)
            else:
                errorContent = errorFile.read()
                htmlContent = re.sub('<QSEmbedUrl>', 'response', errorContent)
                #htmlContent = re.sub('<QSEmbedUrl>', 'response','Access Denied')                
        elif mode == 'static':
            #Replace API Gateway url placeholder
            htmlContent = re.sub('<QSApiGatewayUrl>', apiGatewayUrl, htmlContent)
            
        #Return HTML. 
        return {'statusCode':200,
            'headers': {"Content-Type":"text/html"},
            'body':htmlContent
            }
    else:
        #Return response from get-dashboard-embed-url call.
        #Access-Control-Allow-Origin doesn't come into play in this sample as origin is the API Gateway url itself.
        #When using the static mode wherein initial static HTML is loaded from a different domain, this header becomes relevant.
        #You can change to the specific origin domain from * to secure further.  
        return {'statusCode':200,
                'headers': {"Access-Control-Allow-Origin": "*",
                            "Content-Type":"text/plain"},
                'body':json.dumps(response)
                } 


def getQuickSightDashboardUrl(awsAccountId, dashboardIdList, dashboardRegion):
    #Create QuickSight client
    quickSight = boto3.client('quicksight', region_name=dashboardRegion);

    #Generate Anonymous Embed url
    response = quickSight.get_dashboard_embed_url(
             AwsAccountId = awsAccountId,
             Namespace = 'default',
             DashboardId = dashboardIdList[0],
             AdditionalDashboardIds=dashboardIdList,
             IdentityType = 'ANONYMOUS',
             SessionLifetimeInMinutes = 15,
             UndoRedoDisabled = True,
             ResetDisabled= True
         )
    return response
