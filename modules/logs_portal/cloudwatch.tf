resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_logs_portal" {
  name              = "/aws/codebuild/${var.v_logs_portal_function_name}"
  retention_in_days = 1827
}

resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_ssm_logs_portal_ecs" {
  name              = "/ecs/${var.v_logs_portal_function_name}"
  retention_in_days = 1827
}

resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_ssm_activation" {
  name              = "/aws/lambda/${var.v_logs_portal_get_activation_codes_function_name}"
  retention_in_days = 1827
}
