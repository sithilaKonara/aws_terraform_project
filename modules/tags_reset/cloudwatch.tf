#Create  cloud watch log group for ssm-tags_reset code build.
resource "aws_cloudwatch_log_group" "r_cw_tagsReset" {
  name              = "/aws/codebuild/${var.v_function_name}"
  retention_in_days = 1827
}

#Create  cloud watch log group for ssm-tags_reset_ecs lambda function.
resource "aws_cloudwatch_log_group" "r_cw_lambda_ssm-tags_reset_ecs" {
  name              = "/aws/lambda/${var.v_function_name}_ecs"
  retention_in_days = 1827
}

#Create  cloud watch log group for ssm-tags_reset_ecs ECS container.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_ssm-tags_reset_ecs" {
  name              = "/ecs/${var.v_function_name}"
  retention_in_days = 1827
}
