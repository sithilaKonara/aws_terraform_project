#Zip soucrce files
data "archive_file" "d_ssm_generate_embeded_url_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/Documents/Lambda/SSM-Generate-patch-anonymous-embed-url"
  output_path = "${path.module}/Documents/Lambda/Zip/SSM-Generate-patch-anonymous-embed-url.zip"
}
#Create lambda function AutomationHandler
resource "aws_lambda_function" "r_lambda_ssm_generate_embed_url" {
  filename      = data.archive_file.d_ssm_generate_embeded_url_lambda_zip.output_path
  function_name = var.v_pdt_embbeded_url_lamda_function_name
  description   = "Generate custom embeded url to display quicksight dashboard on neo page"
  # handler       = "${var.v_pdt_embbeded_url_lamda_function_name}.lambda_handler"
  handler = "lambda_function.lambda_handler"
  role    = aws_iam_role.r_role_ssm_QSAnonymousEmbedRole.arn
  #Check source code change
  source_code_hash = data.archive_file.d_ssm_generate_embeded_url_lambda_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 600

  environment {
    variables = {
      DashboardIdList   = "f14aab3d-ad2b-4577-a51f-f4dc3e989a1a" //need to add
      DashboardNameList = "ABC Company Global Patch Deployment Tracker"
      DashboardRegion   = var.v_aws_region
      URL               = "https://url.sharepoint.com/"
    }
  }

  depends_on = [
    data.archive_file.d_ssm_generate_embeded_url_lambda_zip
  ]
}

resource "aws_lambda_permission" "allow_api" {
  statement_id  = "Invoke_lambda_by_api_gateway_resource"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.r_lambda_ssm_generate_embed_url.function_name
  principal     = "apigateway.amazonaws.com"
  # source_arn    = "${aws_api_gateway_rest_api.r_apig_pdt.execution_arn}/*/*/*"
  source_arn = "${aws_api_gateway_rest_api.r_apig_pdt.execution_arn}/*/GET/${var.v_pdt_name.name}-embed-url"
  depends_on = [
    aws_api_gateway_deployment.r_apigd_pdt,
    aws_api_gateway_integration.r_apigi_pdt
  ]
}
