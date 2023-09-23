#Create  cloud watch log group for ms_teams_notifications lambda
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_ssm_ms_teams_notifications" {
  name              = "/aws/lambda/${var.v_ms_teams_notifications_function_name}"
  retention_in_days = 3653
}



