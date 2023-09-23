resource "aws_cloudwatch_log_group" "r_ssm_patch_completion_log_group" {
  name              = "/aws/codebuild/${var.v_patch_completion_function_name}"
  retention_in_days = 1827
}


#Create  cloud watch log group for ssm-patching_completion lambda function.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_lambda_ssm-patching_completion_ecs" {
  name              = "/aws/lambda/${var.v_patch_completion_function_name}_ecs"
  retention_in_days = 1827
}
#Create  cloud watch log group for ssm-patching_completion ECS container.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_ssm-patching_completion" {
  name              = "/ecs/${var.v_patch_completion_function_name}"
  retention_in_days = 1827
}
