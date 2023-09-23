#Zip soucrce files
data "archive_file" "d_archive_file_ssm_ms_teams_notifications" {
  type        = "zip"
  source_dir  = "${path.module}/documents/lambda/ssm_ms_teams_notifications"
  output_path = "${path.module}/documents/lambda/zip/ssm_ms_teams_notifications.zip"
}
#Create lambda function ssm-ms_teams_notifications
resource "aws_lambda_function" "r_lambda_function_ssm_ms_teams_notifications" {
  filename      = data.archive_file.d_archive_file_ssm_ms_teams_notifications.output_path
  function_name = var.v_ms_teams_notifications_function_name
  description   = "Send notifications to MS Teams 30 minutes before each patching cycle"
  role          = aws_iam_role.r_iam_role_code_build_ssm_ms_teams_notifications.arn
  handler       = "lambda_function.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_ms_teams_notifications.output_base64sha256
  runtime          = "python3.9"
  timeout          = 900

  environment {
    variables = {
      FILE_NAME = "documents/change-tickets.csv"
      S3_BUCKET = "${var.v_ms_teams_notifications_s3_bucket.id}"
    }
  }
}

#Configure ssm-tags_reset lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_ms_teams_notifications" {
  statement_id  = "Allow_lambda_execution_on_eventbridge_rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_function_ssm_ms_teams_notifications.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_cloudwatch_event_rules_ms_teams_notifications.arn
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_ms_teams_notifications
  ]
}
