#Create  cloud watch log group for tag_handler code build.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_tag_handler" {
  name              = "/aws/codebuild/${var.v_tag_handler_function_name}"
  retention_in_days = 1827
}

#Create  cloud watch log group for tags_handler_ecs lambda function.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_lambda_ssm-tags_handler_ecs" {
  name              = "/aws/lambda/${var.v_tag_handler_function_name}_ecs"
  retention_in_days = 1827
}

#Create  cloud watch log group for tags_handler_ecs lambda function.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_ecs_ssm-tags_handler" {
  name              = "/aws/ecs/${var.v_tag_handler_function_name}"
  retention_in_days = 1827
}
