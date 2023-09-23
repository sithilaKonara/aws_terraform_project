resource "aws_cloudwatch_event_rule" "r_ssm_patch_completion_rule" {
  name                = var.v_patch_completion_function_name
  description         = "Trigger patch completion Lambda function"
  schedule_expression = "cron(10 6,12,18,00 * * ? *)"
  is_enabled          = false
}

resource "aws_cloudwatch_event_target" "r_ssm_patch_completion_target" {
  target_id = aws_lambda_function.r_ssm_patch_completion_lambda.function_name
  rule      = aws_cloudwatch_event_rule.r_ssm_patch_completion_rule.name
  arn       = aws_lambda_function.r_ssm_patch_completion_lambda.arn

  input = <<EOL
    {
        "Duration": "1",
        "Unit": "hours"
    }
    EOL
  # run_command_targets {
  #     key = "tag:Duration"
  #     values = ["1"]
  # }
  # run_command_targets {
  #     key = "tag:Unit"
  #     values = ["hours"]      
  # }
}
