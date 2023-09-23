#Create event bridge rules
resource "aws_cloudwatch_event_rule" "r_cloudwatch_event_rules_email_handler" {
  for_each            = var.v_email_handler_eventbridge_rules
  name                = each.value[0]
  description         = "Put schedules to send email notificationsss"
  schedule_expression = each.value[1]
  is_enabled          = false
}

#Connect target to the patchscheduler
resource "aws_cloudwatch_event_target" "r_cloudwatch_event_target" {
  for_each  = var.v_email_handler_eventbridge_rules
  rule      = aws_cloudwatch_event_rule.r_cloudwatch_event_rules_email_handler[each.key].name
  target_id = aws_lambda_function.r_lambda_function_ssm_email_handler_ecs.function_name
  arn       = aws_lambda_function.r_lambda_function_ssm_email_handler_ecs.arn
  input     = <<DOC
    {
      "Duration": "${each.value[2]}",
      "Unit": "${each.value[3]}"
    }
  DOC
}
