#Create event bridge rules
resource "aws_cloudwatch_event_rule" "r_cloudwatch_event_rules_hybrid_activation" {
  name                = "SSM-29_days_rule"
  description         = "Triggers every 29 days"
  schedule_expression = "rate(29 days)"
  is_enabled          = false
}

#Connect target to the patchscheduler
resource "aws_cloudwatch_event_target" "r_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.r_cloudwatch_event_rules_hybrid_activation.name
  target_id = aws_lambda_function.r_lambda_function_ssm_hybrid_activation.function_name
  arn       = aws_lambda_function.r_lambda_function_ssm_hybrid_activation.arn
  input     = <<DOC
    {
    }
  DOC
}
