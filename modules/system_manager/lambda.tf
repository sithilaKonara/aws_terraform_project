# Zip soucrce files
data "archive_file" "d_ssm_PatchScheduler_zip" {
  type        = "zip"
  source_file = "${path.module}/Documents/Lambda/SSM-patch_scheduler.py"
  # output_path = "./modules/system_manager/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm_PatchScheduler"]}.zip"
  output_path = "${path.module}/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm_PatchScheduler"]}.zip"
}
# Create lambda function SSM patch scheduler
resource "aws_lambda_function" "r_lambda_SSM_PatchScheduler" {
  # filename      = "${path.module}/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm_PatchScheduler"]}.zip"
  filename      = data.archive_file.d_ssm_PatchScheduler_zip.output_path
  function_name = var.v_system_manager_lambda_functions["ssm_PatchScheduler"]
  description   = "Put schedules to monthly patching maintenance windows"
  role          = aws_iam_role.r_role_SSM_PatchSchedulerLambdaAutomationRole.arn
  handler       = "SSM-patch_scheduler.lambda_handler"
  #Check source code change
  # source_code_hash = filebase64sha256("./modules/system_manager/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm_PatchScheduler"]}.zip")
  source_code_hash = data.archive_file.d_ssm_PatchScheduler_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 600
  environment {
    variables = {
      REGION   = "${var.v_system_manager_aws_region}"
      DATABASE = "${aws_dynamodb_table.r_ssm_patch-maintenance-windows.id}"
    }
  }
}
# Configure Lambda resouece based policy(PatchScheduler)
resource "aws_lambda_permission" "r_lambda_permission" {
  statement_id  = "AllowAccesstoEventBridgeRule${aws_cloudwatch_event_rule.r_eb_patchschduler.name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_SSM_PatchScheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_eb_patchschduler.arn
}


#Zip soucrce files
data "archive_file" "d_ssm_AutomationHandler_zip" {
  type        = "zip"
  source_file = "${path.module}/Documents/Lambda/SSM-automation_handler.py"
  output_path = "${path.module}/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm_AutomationHandler"]}.zip"
}
#Create lambda function SSM automation handler
resource "aws_lambda_function" "r_lambda_SSM_AutomationHandler" {
  # filename      = "./modules/system_manager/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm_AutomationHandler"]}.zip"
  filename      = data.archive_file.d_ssm_AutomationHandler_zip.output_path
  function_name = var.v_system_manager_lambda_functions["ssm_AutomationHandler"]
  description   = "Initiate instances patching on maintenance window event"
  role          = aws_iam_role.r_role_SSM_PatchHandlerLambdaAutomationRole.arn
  handler       = "SSM-automation_handler.lambda_handler"
  #Check source code change
  # source_code_hash = filebase64sha256("./modules/system_manager/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm_AutomationHandler"]}.zip")
  source_code_hash = data.archive_file.d_ssm_AutomationHandler_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 600

  environment {
    variables = {
      ASSUME_EXECUTION_ROLE = aws_iam_role.r_role_ssm_AutomationExecutionRole.name
      S3_TARGET_BUCKET      = "ssm-logs-ap-southeast-1"
      SNS_ARN               = aws_sns_topic.r_ssm_cps.arn #### > name to ARN < ####
      DATABASE              = "${aws_dynamodb_table.r_ssm_patch_deployment_tracker.id}"
    }
  }
}

#Zip soucrce files
data "archive_file" "d_SSM-DeleteGlueTableColumnFunction_zip" {
  type        = "zip"
  source_file = "${path.module}/Documents/Lambda/SSM-DeleteGlueTableColumnFunction.py"
  output_path = "${path.module}/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm-DeleteGlueTableColumnFunction"]}.zip"
}
#Create lambda function SSM delete glue table cloumn functions
resource "aws_lambda_function" "r_SSM-DeleteGlueTableColumnFunction" {
  # filename      = "./modules/system_manager/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm-DeleteGlueTableColumnFunction"]}.zip"
  filename      = data.archive_file.d_SSM-DeleteGlueTableColumnFunction_zip.output_path
  function_name = var.v_system_manager_lambda_functions["ssm-DeleteGlueTableColumnFunction"]
  description   = "Deletes the 'resourcetype' Glue table that causes an issue when loading partitions in Athena"
  role          = aws_iam_role.r_SSM-DeleteGlueTableColumnFunctionRole.arn
  handler       = "SSM-DeleteGlueTableColumnFunction.lambda_handler"
  #Check source code change
  # source_code_hash = filebase64sha256("./modules/system_manager/Documents/Lambda/Zip/${var.v_system_manager_lambda_functions["ssm-DeleteGlueTableColumnFunction"]}.zip")
  source_code_hash = data.archive_file.d_SSM-DeleteGlueTableColumnFunction_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 600
  environment {
    variables = {
      CRAWLER_NAME  = "SSM-GlueCrawler"
      DATABASE_NAME = "${var.v_system_manager_glue_db}"
    }
  }
  depends_on = [
    aws_iam_role.r_SSM-DeleteGlueTableColumnFunctionRole, aws_glue_crawler.r_ssmGlueCrawler
  ]
}
#Configure Lambda resouece based policy for SSM delete glue table column function)
resource "aws_lambda_permission" "r_allow_cloudwatch_to_call_gluetabledeletelambda" {
  #Statement_id needs to be checked
  statement_id  = "SSM-ConfigureMasterAccount-DeleteGlueTableColumnFunctionCloudWatchPermission-1X9WZ70MN8LUT" # Need to check
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_SSM-DeleteGlueTableColumnFunction.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_ssm-DeleteGlueTableColumn.arn
}
