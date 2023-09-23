#Zip soucrce files
data "archive_file" "d_archive_file_ssm_tag_handler_ecs" {
  type        = "zip"
  source_file = "${path.module}/documents/lambda/SSM-tag_handler_ecs.py"
  output_path = "${path.module}/documents/lambda/zip/ssm_tag_handler_ecs.zip"
}
#Create lambda function ssm-tags_handler
resource "aws_lambda_function" "r_lambda_function_ssm_tag_handler_ecs" {
  filename      = data.archive_file.d_archive_file_ssm_tag_handler_ecs.output_path
  function_name = "${var.v_tag_handler_function_name}_ecs"
  description   = "Update SSM manage instances tags"
  role          = var.v_tag_handler_iam_roles["lambdaECS"]
  handler       = "SSM-tag_handler_ecs.lambda_handler"

  #Check source code change
  source_code_hash = data.archive_file.d_archive_file_ssm_tag_handler_ecs.output_base64sha256
  runtime          = "python3.9"
  timeout          = 600

  environment {
    variables = {
      DATABASE_NAME           = "${var.v_tag_handler_glue_ssm_global_resource_sync_database}"
      OUTPUT_ATHENA_S3_BUCKET = "${var.v_tag_handler_s3_bucket_athena_query_result}"
      SNS_ARN                 = "${var.v_tag_handler_sns_ssm_arn}"
      ASSUME_EXECUTION_ROLE   = "${var.v_tag_handler_iam_role_automation_execution["ssm-automationExecutionRole_name"]}"
      PRIVATE_SUBNETS         = "${var.v_tag_handler_vpc_private_subnets["ssm-vpn-private-01"]},${var.v_tag_handler_vpc_private_subnets["ssm-vpn-private-02"]}"
      TASK_DEFINITION         = "${var.v_tag_handler_function_name}:${aws_ecs_task_definition.r_ecs_task_definition_ssm_tag_handler.revision}"
      TASK_NAME               = "${var.v_tag_handler_function_name}"
    }
  }
  depends_on = [
    aws_ecs_task_definition.r_ecs_task_definition_ssm_tag_handler
  ]
}

#Configure ssm-tags_reset lambda trigger
resource "aws_lambda_permission" "r_lambda_permission_ssm_tag_handler_ecs" {
  statement_id   = "Allow_lambda_execution_on_S3_event"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.r_lambda_function_ssm_tag_handler_ecs.function_name
  principal      = "s3.amazonaws.com"
  source_account = var.v_tag_handler_aws_account
  source_arn     = aws_s3_bucket.r_s3_bucket_ssm_tag_handler.arn
  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_tag_handler_ecs,
    aws_s3_bucket.r_s3_bucket_ssm_tag_handler
  ]
}
