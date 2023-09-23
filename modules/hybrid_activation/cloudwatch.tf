#Create  cloud watch log group for hybrid_activation lambda
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_ssm_hybrid_activation" {
  name              = "/aws/lambda/${var.v_hybrid_activation_function_name}"
  retention_in_days = 3653
}
