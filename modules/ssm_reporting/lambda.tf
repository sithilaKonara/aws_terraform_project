#Zip soucrce files
data "archive_file" "d_ssm_reporting_ecs_zip" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/ssm-reporting_ecs.py"
  output_path = "${path.module}/documents/lambda/zip/ssm-reporting_ecs.zip"
}

resource "aws_lambda_function" "r_ssm_ecs_reporting" {
  function_name = "${var.v_function_name}_ecs"
  description   = "Store monthly pathing data to DynamoDB table"
  filename      = data.archive_file.d_ssm_reporting_ecs_zip.output_path
  role          = var.v_ecsTaskExecutionRole["lambdaECS"] # Check whether this is required ${} syntax
  handler       = "ssm-reporting_ecs.lambda_handler"

  source_code_hash = data.archive_file.d_ssm_reporting_ecs_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 300

  environment {
    variables = {
      ASSUME_EXECUTION_ROLE = "${var.v_automationExecutionRole["ssm-automationExecutionRole_name"]}"
      TASK_DEFINITION       = "${var.v_function_name}:${aws_ecs_task_definition.r_ssm_store_patch_data.revision}"
      PRIVATE_SUBNETS       = "${var.v_s_private["ssm-vpn-private-01"]},${var.v_s_private["ssm-vpn-private-02"]}"
      TASK_NAME             = "${var.v_function_name}"
      DATABASE              = "${var.v_ssm_eporting_dynamodb_table}"
    }
  }
}

resource "aws_lambda_permission" "r_ssm_ReportingECS_trigger" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_ssm_ecs_reporting.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_ssm_reporting_rule.arn
}
