#Zip soucrce files
data "archive_file" "d_archive_file_ssm_patch_failure_report" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/ssm-patch_failure_report.py"
  output_path = "${path.module}/documents/lambda/zip/ssm-patch_failure_report.zip"
}

#Create lambda function ssm-tags_handler
resource "aws_lambda_function" "r_lambda_function_ssm_patch_failure_report" {
  filename      = data.archive_file.d_archive_file_ssm_patch_failure_report.output_path
  function_name = var.v_patch_failure_report_function_name
  description   = "Send monthly patching failure server report to business units."
  role          = aws_iam_role.r_iam_role_code_build_ssm_patch_failure_report.arn
  handler       = "ssm-patch_failure_report.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_patch_failure_report.output_base64sha256
  runtime          = "python3.9"
  timeout          = 600

  environment {
    variables = {
      ASSUME_EXECUTION_ROLE = "${var.v_patch_failure_report_iam_role_automation_execution["ssm-automationExecutionRole_name"]}"
      REGION                = "${var.v_patch_failure_report_region}"
      TABLE                 = "${var.v_patch_failure_report_monthly_patching_data_dynamodb_table}"
    }
  }
}

#Configure patch_failure_report lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_patch_failure_report" {
  statement_id  = "Allow_lambda_execution_on_eventbridge_rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_function_ssm_patch_failure_report.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.v_patch_failure_report_eventbridge.arn
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_patch_failure_report,
  ]
}
