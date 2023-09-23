data "archive_file" "d_ssm_patch_completion_ecs_zip" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/SSM-patching_completion.py"
  output_path = "${path.module}/documents/lambda/zip/SSM-patching_completion.zip"
}

resource "aws_lambda_function" "r_ssm_patch_completion_lambda" {
  description   = "Lambda function to send patching completion emails and to capture failed servers"
  filename      = data.archive_file.d_ssm_patch_completion_ecs_zip.output_path
  function_name = "${var.v_patch_completion_function_name}_ecs"
  handler       = "SSM-patching_completion.lambda_handler"
  # source_code_hash = filebase64sha256("./patch_completion/documents/lambda/zip/ssm-patching_completion.zip")
  source_code_hash = data.archive_file.d_ssm_patch_completion_ecs_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 900
  memory_size      = 160
  role             = var.v_patch_completion_ecsTaskExecutionRole["lambdaECS"]

  environment {
    variables = {
      ASSUME_EXECUTION_ROLE = "${var.v_patch_completion_iam_role_automation_execution["ssm-automationExecutionRole_name"]}"
      AWS_SES_REGION        = "${var.v_patch_completion_reagion}"
      DATABASE              = "${var.v_patch_completion_ssm_global_resource_sync_database}"
      DATABASE_PDT          = "${var.v_patch_completion_pdt_table.id}"
      DATABASE_MPF          = "${var.v_patch_completion_monthly_patching_failures_db_table.id}"
      S3_BUCKET             = "${var.v_patch_completion_ssm_tag_instance_s3.bucket}"
      S3_OUTPUT_BUCKET      = var.v_patch_completion_s3_bucket_athena_query_result
      PRIVATE_SUBNETS       = "${var.v_patch_completion_subnet_private["ssm-vpn-private-01"]},${var.v_patch_completion_subnet_private["ssm-vpn-private-02"]}"
      TASK_DEFINITION       = "${var.v_patch_completion_function_name}:${aws_ecs_task_definition.r_patch_completion.revision}"
      EMAIL_TAG_1           = var.v_patch_completion_resource_tags["v_pc_email_tag_1"]
      EMAIL_TAG_2           = var.v_patch_completion_resource_tags["v_pc_email_tag_2"]
      EMAIL_TAG_3           = var.v_patch_completion_resource_tags["v_pc_email_tag_3"]
      EMAIL_TAG_4           = var.v_patch_completion_resource_tags["v_pc_email_tag_4"]
      EMAIL_TAG_5           = var.v_patch_completion_resource_tags["v_pc_email_tag_5"]
      EMAIL_TAG_6           = var.v_patch_completion_resource_tags["v_pc_email_tag_6"]
      EMAIL_TAG_7           = var.v_patch_completion_resource_tags["v_pc_email_tag_7"]
      EMAIL_TAG_8           = var.v_patch_completion_resource_tags["v_pc_email_tag_8"]
      EMAIL_TAG_9           = var.v_patch_completion_resource_tags["v_pc_email_tag_9"]
      EMAIL_TAG_10          = var.v_patch_completion_resource_tags["v_pc_email_tag_10"]
      FILE_NAME             = var.v_patch_completion_resource_tags["v_pc_file_name"]
      HOST_NAME_TAG         = var.v_patch_completion_resource_tags["v_pc_hostname_tag"]
      SENDER                = var.v_patch_completion_resource_tags["t_sender"]
      TASK_NAME             = var.v_patch_completion_function_name
    }
  }

}

resource "aws_lambda_permission" "r_ssm_patch_completion_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_ssm_patch_completion_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.r_ssm_patch_completion_rule.arn

}
