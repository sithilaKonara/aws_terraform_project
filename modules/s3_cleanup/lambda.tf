#Zip soucrce files
data "archive_file" "d_archive_file_ssm_s3_cleanup" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/ssm-s3_cleanup.py"
  output_path = "${path.module}/documents/lambda/zip/ssm-s3_cleanup.zip"
}
#Create lambda function ssm-s3_cleanup
resource "aws_lambda_function" "r_lambda_function_ssm_s3_cleanup" {
  filename      = data.archive_file.d_archive_file_ssm_s3_cleanup.output_path
  function_name = var.v_s3_cleanup_function_name
  description   = "Update SSM manage instances tags"
  role          = aws_iam_role.r_iam_role_code_build_ssm_s3_cleanup.arn
  handler       = "ssm-s3_cleanup.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_s3_cleanup.output_base64sha256
  runtime          = "python3.9"
  timeout          = 900

  environment {
    variables = {
      DATABASE_NAME         = "${var.v_s3_cleanup_global_resource_sync_database}"
      S3_OUTPUT_BUCKET      = "${var.v_s3_cleanup_s3_bucket_athena_query_result}"
      SNS_ARN               = "${var.v_s3_cleanup_ssm_sns_arn}"
      ASSUME_EXECUTION_ROLE = "${var.v_s3_cleanup_iam_role_automation_execution["ssm-automationExecutionRole_name"]}"
      S3_BUCKET             = "${var.v_s3_cleanup_global_resource_sync_s3_bucket}"
    }
  }
}

#Configure ssm-tags_reset lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_s3_cleanup" {
  statement_id  = "Allow_lambda_execution_on_eventbridge_rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_function_ssm_s3_cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_cloudwatch_event_rules_s3_cleanup.arn
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_s3_cleanup
  ]
}
