#Create  cloud watch log group for email_handler code build.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_email_handler" {
  name              = "/aws/codebuild/${var.v_email_handler_function_name}"
  retention_in_days = 1827
}

#Create  cloud watch log group for email_handler_ecs lambda function.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_lambda_ssm-email_handler_ecs" {
  name              = "/aws/lambda/${var.v_email_handler_function_name}_ecs"
  retention_in_days = 1827
}

#Create  cloud watch log group for email_handler_ecs lambda function.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_ecs_ssm-email_handler" {
  name              = "/aws/ecs/${var.v_email_handler_function_name}"
  retention_in_days = 1827
}
