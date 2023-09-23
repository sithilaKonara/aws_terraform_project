resource "aws_api_gateway_rest_api" "r_apig_pdt" {
  name        = var.v_pdt_name.name
  description = "${var.v_pdt_name.name} Rest API GW"
  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "r_apigr_pdt" {
  parent_id   = aws_api_gateway_rest_api.r_apig_pdt.root_resource_id
  path_part   = "${var.v_pdt_name.name}-embed-url"
  rest_api_id = aws_api_gateway_rest_api.r_apig_pdt.id
}

resource "aws_api_gateway_method" "r_apigm_pdt" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.r_apigr_pdt.id
  rest_api_id   = aws_api_gateway_rest_api.r_apig_pdt.id
}

resource "aws_api_gateway_integration" "r_apigi_pdt" {
  http_method             = aws_api_gateway_method.r_apigm_pdt.http_method
  resource_id             = aws_api_gateway_resource.r_apigr_pdt.id
  rest_api_id             = aws_api_gateway_rest_api.r_apig_pdt.id
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.r_lambda_ssm_generate_embed_url.invoke_arn
}

resource "aws_api_gateway_method_response" "r_apigmr_pdt" {
  rest_api_id = aws_api_gateway_rest_api.r_apig_pdt.id
  resource_id = aws_api_gateway_resource.r_apigr_pdt.id
  http_method = aws_api_gateway_method.r_apigm_pdt.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "r_apigir_pdt" {
  rest_api_id = aws_api_gateway_rest_api.r_apig_pdt.id
  resource_id = aws_api_gateway_resource.r_apigr_pdt.id
  http_method = aws_api_gateway_method.r_apigm_pdt.http_method
  status_code = aws_api_gateway_method_response.r_apigmr_pdt.status_code

  depends_on = [
    aws_api_gateway_method.r_apigm_pdt,
    aws_api_gateway_method_response.r_apigmr_pdt,
    aws_api_gateway_resource.r_apigr_pdt,
    aws_api_gateway_rest_api.r_apig_pdt,
    aws_api_gateway_integration.r_apigi_pdt
  ]
}

resource "aws_api_gateway_deployment" "r_apigd_pdt" {
  rest_api_id = aws_api_gateway_rest_api.r_apig_pdt.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.r_apigr_pdt.id,
      aws_api_gateway_method.r_apigm_pdt.id,
      aws_api_gateway_integration.r_apigi_pdt.id,
      aws_api_gateway_method_response.r_apigmr_pdt,
      aws_api_gateway_integration_response.r_apigir_pdt
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "r_apigs_pdt" {
  deployment_id = aws_api_gateway_deployment.r_apigd_pdt.id
  rest_api_id   = aws_api_gateway_rest_api.r_apig_pdt.id
  stage_name    = "prod"
  depends_on = [
    aws_api_gateway_deployment.r_apigd_pdt
  ]
}
