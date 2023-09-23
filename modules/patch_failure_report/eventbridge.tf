resource "aws_cloudwatch_event_target" "r_eb_cloudwatch_event_patch_failure_report_target" {
  rule      = var.v_patch_failure_report_eventbridge.name
  target_id = aws_lambda_function.r_lambda_function_ssm_patch_failure_report.function_name
  arn       = aws_lambda_function.r_lambda_function_ssm_patch_failure_report.arn
}
