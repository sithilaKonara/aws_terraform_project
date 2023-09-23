# Create IAM role for SSM automation administration
resource "aws_iam_role" "r_role_ssm_AutomationAdministrationRole" {
  # name                 = "${var.v_system_manager_iam_roles["ssm-AutomationAdministrationRole"]}-${var.v_system_manager_aws_account}" #### > Existed value < ####
  name                 = var.v_system_manager_iam_roles["ssm-AutomationAdministrationRole"]
  description          = "Allow SSM automation document execution permission on member accounts "
  path                 = "/"
  max_session_duration = 3600
  inline_policy {
    name   = "AssumeRole-AWSSystemsManagerAutomationExecutionRole"
    policy = data.aws_iam_policy_document.d_ssm_AutomationAdministrationRole.json
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      },
    ]
  })
}

# Create IAM role for SSM automation execution role
resource "aws_iam_role" "r_role_ssm_AutomationExecutionRole" {
  # name                 = "${var.v_system_manager_iam_roles["ssm-AutomationExecutionRole"]}-${var.v_system_manager_aws_account}" #### > Existed value < ####
  name                 = var.v_system_manager_iam_roles["ssm-AutomationExecutionRole"]
  description          = "Allows SSM to call AWS services on your behalf"
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"]
  inline_policy {
    name   = "ExecutionPolicy"
    policy = data.aws_iam_policy_document.d_ssm_AutomationExecutionRole.json
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.v_system_manager_aws_account}:root"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      },
    ]
  })
}

# Create IAM role for SSM patch handler lambda automation
resource "aws_iam_role" "r_role_SSM_PatchHandlerLambdaAutomationRole" {
  name                 = "${var.v_system_manager_iam_roles["SSM_PatchHandlerLambdaAutomationRole"]}-LambdaExecution-${var.v_system_manager_aws_account}"
  description          = "null"
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  ]
  inline_policy {
    name   = "LambdaExecutionPolicy"
    policy = data.aws_iam_policy_document.d_ssm_AutomationHandler.json
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

#Create IAM policy AWSQuickSightS3ConsumersPolicy
resource "aws_iam_policy" "r_policy_AWSQuickSightS3ConsumersPolicy" {
  name        = "${var.v_system_manager_iam_policies["AWSQuickSightS3ConsumersPolicy"]}-${var.v_system_manager_aws_account}"
  description = "Grants Amazon QuickSight read permission to Amazon S3 resources"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_AWSQuickSightS3ConsumersPolicy.json
}
#Create IAM role aws-quicksight-s3-consumers-role-v0
resource "aws_iam_role" "r_role_QuicksightS3ConsumersRole" {
  name                 = "${var.v_system_manager_iam_roles["QuicksightS3ConsumersRole"]}-${var.v_system_manager_aws_account}"
  description          = "null"
  path                 = "/service-role/"
  max_session_duration = 3600
  managed_policy_arns = [
    aws_iam_policy.r_policy_AWSQuickSightS3ConsumersPolicy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSQuicksightAthenaAccess"
  ]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "quicksight.amazonaws.com"
        }
      },
    ]
  })
}
#Create IAM role Lambda SSM-PatchScheduler
resource "aws_iam_role" "r_role_SSM_PatchSchedulerLambdaAutomationRole" {
  name                 = "${var.v_system_manager_iam_roles["SSM_PatchSchedulerLambdaAutomationRole"]}-LambdaExecution-${var.v_system_manager_aws_account}" #### > Existed value < ####
  description          = "null"
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonSSMFullAccess", "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  inline_policy {
    name   = "LambdaExecutionPolicy"
    policy = data.aws_iam_policy_document.d_SSM_PatchScheduler.json
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}


# Create IAM role for glue service
resource "aws_iam_role" "r_AWSGlueServiceRole" {
  name                = "${var.v_system_manager_iam_roles["GlueCrawlerRole"]}-${var.v_system_manager_aws_account}"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"]
  #Trust relationship for SSM-GlueCrawlerRole role
  assume_role_policy = file("./modules/system_manager/Documents/trust_relationships/glue.json")
  #Attached polocies
  inline_policy {
    name = "s3Actions"
    #Need to add KMS to JSON file
    policy = data.aws_iam_policy_document.d_s3Action.json
  }
}
#Creating SSM-DeleteGlueTableColumnFunctionRole Role for Lambda
resource "aws_iam_role" "r_SSM-DeleteGlueTableColumnFunctionRole" {
  #name                = format("${var.v_iam_roles["ssm-DeleteGlueTableColumnFunctionRole"]}%s", data.aws_caller_identity.current.account_id)
  name                = "${var.v_system_manager_iam_roles["ssm-DeleteGlueTableColumnFunctionRole"]}-LambdaExecution-${var.v_system_manager_aws_account}"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  #Trust relationship for SSM-DeleteGlueTableColumnFunctionRole
  assume_role_policy = file("./modules/system_manager/Documents/trust_relationships/deletegluetablecolumnfunctionlambda.json")
  #Attached policies
  inline_policy {
    name   = "GlueAction"
    policy = data.aws_iam_policy_document.d_GlueAction.json
  }
}
