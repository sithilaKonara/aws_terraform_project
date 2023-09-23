#Create eventbridge rule patchscheduler
resource "aws_cloudwatch_event_rule" "r_eb_patchschduler" {
  name                = var.v_system_manager_eb_rules["eb_patchscheduler"]
  description         = "Put schedules to patching maintenance windows"
  is_enabled          = false
  schedule_expression = "cron(0 5 ? * 3#2 *)" # Actual time to trigger
  depends_on = [
    aws_lambda_function.r_lambda_SSM_PatchScheduler
  ]
}
#Connect target to the patchscheduler
resource "aws_cloudwatch_event_target" "r_eb_patchschduler_target" {
  rule      = aws_cloudwatch_event_rule.r_eb_patchschduler.name
  target_id = aws_lambda_function.r_lambda_SSM_PatchScheduler.function_name
  arn       = aws_lambda_function.r_lambda_SSM_PatchScheduler.arn
}
#Setting up EventBridge for Lambda ssm-DeleteGlueTableColumn
resource "aws_cloudwatch_event_rule" "r_ssm-DeleteGlueTableColumn" {
  name          = var.v_system_manager_eb_rules["eb_SSM-DeleteGlueTableColumn"]
  description   = "Deletes resourcetype from Glue table"
  is_enabled    = true
  event_pattern = <<PATTERN
  {
    "detail-type": ["Glue Crawler State Change"],
    "source": ["aws.glue"],
    "detail": {
      "state": ["Succeeded"]}
  }
PATTERN
  depends_on = [
    aws_lambda_function.r_SSM-DeleteGlueTableColumnFunction
  ]
}
#Connect target to the SSM-DeleteGlueTableColumnFunction
resource "aws_cloudwatch_event_target" "r_SSM-DeleteGlueTableColumnFunction" {
  rule      = aws_cloudwatch_event_rule.r_ssm-DeleteGlueTableColumn.name
  target_id = aws_lambda_function.r_SSM-DeleteGlueTableColumnFunction.function_name
  arn       = aws_lambda_function.r_SSM-DeleteGlueTableColumnFunction.arn
}


