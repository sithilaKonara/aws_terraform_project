#Zip soucrce files
data "archive_file" "d_archive_file_ssm_connection_lost_servers" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/ssm_connection_lost_servers_ecs.py"
  output_path = "${path.module}/documents/lambda/zip/ssm_connection_lost_servers_ecs.zip"
}
#Create lambda function ssm-connection_lost_servers
resource "aws_lambda_function" "r_lambda_function_ssm_connection_lost_servers" {
  filename      = data.archive_file.d_archive_file_ssm_connection_lost_servers.output_path
  function_name = "${var.v_connection_lost_servers_function_name}_ecs"
  description   = "Spin up ECS contaier to execute connection lost servers script"
  role          = var.v_connection_lost_servers_lambda_ecs_iam_roles["lambdaECS"]
  handler       = "ssm_connection_lost_servers_ecs.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_connection_lost_servers.output_base64sha256
  runtime          = "python3.9"
  timeout          = 900

  environment {
    variables = {
      ASSUME_EXECUTION_ROLE = "${var.v_connection_lost_servers_iam_role_automation_execution["ssm-automationExecutionRole_name"]}"
      ACCOUNT_IDS           = "${var.v_connection_lost_servers_member_accounts["ACCOUNT_IDS"]}"
      AWS_REGIONS           = "${var.v_connection_lost_servers_member_accounts["AWS_REGIONS"]}"
    }
  }
}

#Configure ssm-tags_reset lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_connection_lost_servers" {
  statement_id  = "Allow_lambda_execution_on_eventbridge_rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_function_ssm_connection_lost_servers.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_ssm_connection_lost_servers_rule.arn
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_connection_lost_servers
  ]
}
