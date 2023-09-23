#Zip soucrce files
data "archive_file" "d_archive_file_ssm_hybrid_activation" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/ssm_hybrid_activation.py"
  output_path = "${path.module}/documents/lambda/zip/ssm_hybrid_activation.zip"
}
#Create lambda function ssm-hybrid_activation
resource "aws_lambda_function" "r_lambda_function_ssm_hybrid_activation" {
  filename      = data.archive_file.d_archive_file_ssm_hybrid_activation.output_path
  function_name = var.v_hybrid_activation_function_name
  description   = "Create Hybrid activations and store in parameter store"
  role          = aws_iam_role.r_iam_role_code_build_ssm_hybrid_activation.arn
  handler       = "ssm_hybrid_activation.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_hybrid_activation.output_base64sha256
  runtime          = "python3.9"
  timeout          = 900

  environment {
    variables = {
      # S3_BUCKET_DR          = "cedr-ce-automation-resources-bucket"
      SNS_ARN               = "${var.v_hybrid_activation_ssm_sns_arn}"
      ASSUME_EXECUTION_ROLE = "${var.v_hybrid_activation_iam_role_automation_execution["ssm-automationExecutionRole_name"]}"
      S3_BUCKET             = "${var.v_hybrid_activation_s3_bucket.id}"
      # ACCOUNT_IDS           = "${var.v_hybrid_activation_member_accounts["ACCOUNT_IDS"]}"
      # AWS_REGIONS           = "${var.v_hybrid_activation_member_accounts["AWS_REGIONS"]}"
      ORCHESTRATOR_ACCOUNT  = var.v_hybrid_activation_account_id
      ORCHESTRATOR_REGION   = var.v_hybrid_activation_region
    }
  }
}

#Configure ssm-tags_reset lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_hybrid_activation" {
  statement_id  = "Allow_lambda_execution_on_eventbridge_rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_function_ssm_hybrid_activation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_cloudwatch_event_rules_hybrid_activation.arn
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_hybrid_activation
  ]
}
