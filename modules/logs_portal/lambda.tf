#Zip soucrce files
data "archive_file" "d_archive_file_ssm_get_activation_codes" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/SSM-get_activation_codes.py"
  output_path = "${path.module}/documents/lambda/zip/SSM-get_activation_codes.zip"
}
#Create lambda function get acttivation codes
resource "aws_lambda_function" "r_lambda_function_ssm_get_activation_codes" {
  filename      = data.archive_file.d_archive_file_ssm_get_activation_codes.output_path
  function_name = var.v_logs_portal_get_activation_codes_function_name
  description   = "Get SSM activation codes for instances registration"
  role          = aws_iam_role.r_iam_role_lambda_get_activation_codes.arn
  handler       = "SSM-get_activation_codes.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_get_activation_codes.output_base64sha256
  runtime          = "python3.9"
  timeout          = 900

  environment {
    variables = {
      File   = "activations/activation.csv"
      Source = "${var.v_logs_portal_s3_bucket.id}"
    }
  }
}

# Configure ssm-tags_reset lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_mi_deregistration" {
  statement_id   = "Allow_lambda_execution_from_api_gateway"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.r_lambda_function_ssm_get_activation_codes.function_name
  principal      = "apigateway.amazonaws.com"
  source_account = var.v_logs_portal_account_id
  source_arn     = "arn:aws:execute-api:${var.v_logs_portal_region}:${var.v_logs_portal_account_id}:${aws_api_gateway_rest_api.r_rest_api_gateway_private.id}/*/POST/ssm_activation"
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_get_activation_codes
  ]
}
