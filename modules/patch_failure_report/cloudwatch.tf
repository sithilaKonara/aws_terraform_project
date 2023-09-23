#Create  cloud watch log group for tags_handler_ecs lambda function.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_lambda_ssm_patch_failure_report" {
  name              = "/aws/lambda/${var.v_patch_failure_report_function_name}"
  retention_in_days = 1827
}
