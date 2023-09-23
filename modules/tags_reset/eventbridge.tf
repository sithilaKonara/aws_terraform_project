# Tags reset eventbridge rule
resource "aws_cloudwatch_event_rule" "r_ssm_tagsReset_rule" {
  name                = var.v_function_name
  description         = "Reset patching related tags on patch Tuesday"
  schedule_expression = "cron(15 0 ? * 3#2 *)"
  is_enabled          = false #### > make it true when go live < ####
}

#Connect event target
resource "aws_cloudwatch_event_target" "r_ssm_tagsReset_target" {
  rule      = aws_cloudwatch_event_rule.r_ssm_tagsReset_rule.name
  target_id = aws_lambda_function.r_lambda_ssm_tagsReset_ecs.function_name
  arn       = aws_lambda_function.r_lambda_ssm_tagsReset_ecs.arn
}
