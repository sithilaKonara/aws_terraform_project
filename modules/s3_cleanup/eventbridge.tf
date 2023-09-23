#Create event bridge rules
resource "aws_cloudwatch_event_rule" "r_cloudwatch_event_rules_s3_cleanup" {
  name                = var.v_s3_cleanup_function_name
  description         = "Put schedules to send S3 cleanup"
  schedule_expression = "cron(30 0 * * ? *)"
  is_enabled          = true
}

#Connect target to the patchscheduler
resource "aws_cloudwatch_event_target" "r_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.r_cloudwatch_event_rules_s3_cleanup.name
  target_id = aws_lambda_function.r_lambda_function_ssm_s3_cleanup.function_name
  arn       = aws_lambda_function.r_lambda_function_ssm_s3_cleanup.arn
  input     = <<DOC
    {
    }
  DOC
}
