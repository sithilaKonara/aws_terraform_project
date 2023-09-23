#Zip soucrce files
data "archive_file" "d_archive_file_ssm_mi_deregistration" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/ssm_mi_deregistration.py"
  output_path = "${path.module}/documents/lambda/zip/ssm_mi_deregistration.zip"
}
#Create lambda function ssm-mi_deregistration
resource "aws_lambda_function" "r_lambda_function_ssm_mi_deregistration" {
  filename      = data.archive_file.d_archive_file_ssm_mi_deregistration.output_path
  function_name = var.v_mi_deregistration_function_name
  description   = "Update SSM manage instances tags"
  role          = aws_iam_role.r_iam_role_code_build_ssm_mi_deregistration.arn
  handler       = "ssm_mi_deregistration.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_mi_deregistration.output_base64sha256
  runtime          = "python3.9"
  timeout          = 900

  environment {
    variables = {
      DATABASE_NAME         = "${var.v_mi_deregistration_global_resource_sync_database}"
      S3_OUTPUT_BUCKET      = "${var.v_mi_deregistration_s3_bucket_athena_query_result}"
      SNS_ARN               = "${var.v_mi_deregistration_ssm_sns_arn}"
      ASSUME_EXECUTION_ROLE = "${var.v_mi_deregistration_iam_role_automation_execution["ssm-automationExecutionRole_name"]}"
    }
  }
}

#Configure ssm-tags_reset lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_mi_deregistration" {
  statement_id   = "Allow_lambda_execution_on_S3_event"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.r_lambda_function_ssm_mi_deregistration.function_name
  principal      = "s3.amazonaws.com"
  source_account = var.v_mi_deregistration_account_id
  source_arn     = var.v_mi_deregistration_s3_bucket.arn
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_mi_deregistration
  ]
}
