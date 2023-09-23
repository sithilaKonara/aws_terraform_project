resource "aws_cloudwatch_event_rule" "r_ssm_connection_lost_servers_rule" {
  name                = var.v_connection_lost_servers_function_name
  description         = "Trigger patch connection lost servers_ecs Lambda function"
  schedule_expression = "cron(30 2 * * ? *)"
  is_enabled          = false
}

resource "aws_cloudwatch_event_target" "r_ssm_connection_lost_servers_target" {
  target_id = aws_lambda_function.r_lambda_function_ssm_connection_lost_servers.function_name
  rule      = aws_cloudwatch_event_rule.r_ssm_connection_lost_servers_rule.name
  arn       = aws_lambda_function.r_lambda_function_ssm_connection_lost_servers.arn

  # input = <<EOL
  #   {
  #       "Duration": "1",
  #       "Unit": "hours"
  #   }
  #   EOL

}
