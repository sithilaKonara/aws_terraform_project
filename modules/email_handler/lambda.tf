#Zip soucrce files
data "archive_file" "d_archive_file_ssm_email_handler_ecs" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/ssm_email_handler_ecs.py"
  output_path = "${path.module}/documents/lambda/zip/ssm_email_handler_ecs.zip"
}
#Create lambda function ssm-tags_handler
resource "aws_lambda_function" "r_lambda_function_ssm_email_handler_ecs" {
  filename      = data.archive_file.d_archive_file_ssm_email_handler_ecs.output_path
  function_name = "${var.v_email_handler_function_name}_ecs"
  description   = "Update SSM manage instances tags"
  role          = var.v_email_handler_iam_roles["lambdaECS"]
  handler       = "ssm_email_handler_ecs.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_email_handler_ecs.output_base64sha256
  runtime          = "python3.9"
  timeout          = 600

  environment {
    variables = {
      AWS_SES_REGION        = "${var.v_email_handler_aws_region}"
      EMAIL_TAG_1           = "OS_PATCHING_TESTER"
      EMAIL_TAG_10          = "APP_SUPPORT_GROUP_2"
      EMAIL_TAG_2           = "PRIMARY_TECHNICAL_OWNER"
      EMAIL_TAG_3           = "PRIMARY_TECHNICAL_OWNER_1"
      EMAIL_TAG_4           = "PRIMARY_TECHNICAL_OWNER_2"
      EMAIL_TAG_5           = "SECONDARY_TECHNICAL_OWNER"
      EMAIL_TAG_6           = "SECONDARY_TECHNICAL_OWNER_1"
      EMAIL_TAG_7           = "SECONDARY_TECHNICAL_OWNER_2"
      EMAIL_TAG_8           = "APP_SUPPORT_GROUP"
      EMAIL_TAG_9           = "APP_SUPPORT_GROUP_1"
      HOST_NAME_TAG         = "FQDN"
      SENDER                = "email@abccompany.com"
      ASSUME_EXECUTION_ROLE = "${var.v_email_handler_iam_role_automation_execution["ssm-automationExecutionRole_name"]}"
      PRIVATE_SUBNETS       = "${var.v_email_handler_vpc_private_subnets["ssm-vpn-private-01"]},${var.v_email_handler_vpc_private_subnets["ssm-vpn-private-02"]}"
      TASK_DEFINITION       = "${var.v_email_handler_function_name}:${aws_ecs_task_definition.r_ecs_task_definition_ssm_email_handler.revision}"
      TASK_NAME             = "${var.v_email_handler_function_name}"
    }
  }
  depends_on = [
    aws_ecs_task_definition.r_ecs_task_definition_ssm_email_handler
  ]
}

#Configure ssm-email_handler lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_email_handler_ecs" {
  for_each      = aws_cloudwatch_event_rule.r_cloudwatch_event_rules_email_handler
  statement_id  = "Allow_lambda_execution_on_eventbridge_rule_${each.value.id}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_function_ssm_email_handler_ecs.function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.arn
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_email_handler_ecs,
    aws_cloudwatch_event_rule.r_cloudwatch_event_rules_email_handler
  ]
}
