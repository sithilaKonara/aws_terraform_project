resource "aws_cloudwatch_event_rule" "r_ssm_reporting_rule" {
    name = var.v_function_name
    description = "EventBridge rule to execute SSM Reporting after Prod-25 completed"
    is_enabled = false

    schedule_expression = "cron(0 12 ? * 1#2 *)"  
}

resource "aws_cloudwatch_event_target" "r_ssm_reporting_target" {
  rule      = aws_cloudwatch_event_rule.r_ssm_reporting_rule.name
  target_id = aws_lambda_function.r_ssm_ecs_reporting.function_name 
  arn       = aws_lambda_function.r_ssm_ecs_reporting.arn
  
}