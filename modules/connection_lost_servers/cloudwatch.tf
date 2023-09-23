#Create  cloud watch log group for connection_lost_servers code build.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_connection_lost_servers" {
  name              = "/aws/codebuild/${var.v_connection_lost_servers_function_name}"
  retention_in_days = 1827
}

#Create  cloud watch log group for connection_lost_servers_ecs lambda function.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_lambda_ssm-tags_handler_ecs" {
  name              = "/aws/lambda/${var.v_connection_lost_servers_function_name}_ecs"
  retention_in_days = 1827
}
