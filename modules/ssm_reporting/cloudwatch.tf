resource "aws_cloudwatch_log_group" "r_cw_ssm_reporting" {
  name = "/aws/codebuild/${var.v_function_name}"
  retention_in_days = 1827
}