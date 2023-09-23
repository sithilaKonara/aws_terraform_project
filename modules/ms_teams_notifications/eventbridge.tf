#Create event bridge rules
resource "aws_cloudwatch_event_rule" "r_cloudwatch_event_rules_ms_teams_notifications" {
  name                = "SSM-30_minutes_rule"
  description         = "Trigger 30 minutes prior to the patch maintenance window"
  schedule_expression = "cron(30 4,10,16,22 * * ? *)"
  is_enabled          = false
}

#Connect target to the patchscheduler
resource "aws_cloudwatch_event_target" "r_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.r_cloudwatch_event_rules_ms_teams_notifications.name
  target_id = aws_lambda_function.r_lambda_function_ssm_ms_teams_notifications.function_name
  arn       = aws_lambda_function.r_lambda_function_ssm_ms_teams_notifications.arn
  input     = <<DOC
    {
    }
  DOC
}
