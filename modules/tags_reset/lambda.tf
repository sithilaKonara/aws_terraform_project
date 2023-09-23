#Zip soucrce files
data "archive_file" "d_ssm_tagsReset_ecs_zip" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/ssm-tags_reset_ecs.py"
  output_path = "${path.module}/documents/lambda/zip/ssm-tags_reset_ecs.zip"
}
#Create lambda function ssm-tags_reset
resource "aws_lambda_function" "r_lambda_ssm_tagsReset_ecs" {
  # filename      = "./tags_reset/documents/lambda/zip/ssm-tags_reset_ecs.zip"
  filename      = data.archive_file.d_ssm_tagsReset_ecs_zip.output_path
  function_name = "${var.v_function_name}_ecs"
  description   = "Reset Patching Required, Pre Patching Status, Patching Status and Post Patching Status tags and patch deployment tracker db to default"
  role          = aws_iam_role.r_ssm_lambdaECS.arn
  handler       = "ssm-tags_reset_ecs.lambda_handler"

  #Check source code change
  # source_code_hash = filebase64sha256("./tags_reset/documents/lambda/zip/ssm-tags_reset_ecs.zip")
  source_code_hash = data.archive_file.d_ssm_tagsReset_ecs_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 600

  environment {
    variables = {
      SNS_ARN                  = "${var.v_sns_arn}"
      ASSUME_EXECUTION_ROLE    = "${var.v_automationExecutionRole["ssm-automationExecutionRole_name"]}"
      PATCH_DEPLOYMENT_TRACKER = "${var.v_tags_reset_pdt_table.id}"
      PRIVATE_SUBNETS          = "${var.v_s_private["ssm-vpn-private-01"]}, ${var.v_s_private["ssm-vpn-private-02"]}"
      TASK_DEFINITION          = "${var.v_function_name}:${aws_ecs_task_definition.r_ecsrd_ssm-tagsReset.revision}"
      TASK_NAME                = "${var.v_function_name}"
    }
  }
}

#Configure ssm-tags_reset lambda trigger
resource "aws_lambda_permission" "r_ssm_tagsResetEcs_trigger" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_ssm_tagsReset_ecs.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_ssm_tagsReset_rule.arn
}
