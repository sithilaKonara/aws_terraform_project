#Create  cloud watch log group for SSM delete glue table column lambda function.
resource "aws_cloudwatch_log_group" "r_cloudwatch_log_group_tag_handler" {
  name              = "/aws/lambda/${var.v_system_manager_lambda_functions["ssm-DeleteGlueTableColumnFunction"]}"
  retention_in_days = 1827
}
