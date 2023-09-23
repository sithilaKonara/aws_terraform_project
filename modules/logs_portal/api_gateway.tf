#Create API gateway
resource "aws_api_gateway_rest_api" "r_rest_api_gateway_private" {
  name        = var.v_logs_portal_ssm_private_api_gateway_name
  description = "Private API gateway for SSM"

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.v_logs_portal_api_gateway_vpc_endpoint_id}"]
  }
}

resource "aws_api_gateway_account" "r_rest_api_gateway_clouwatch_log" {
  cloudwatch_role_arn = aws_iam_role.r_iam_role_api_gateway_cloudwatch_log.arn
}

#Create API gateway resouce
resource "aws_api_gateway_resource" "r_resource_ssm_activation" {
  rest_api_id = aws_api_gateway_rest_api.r_rest_api_gateway_private.id
  parent_id   = aws_api_gateway_rest_api.r_rest_api_gateway_private.root_resource_id
  path_part   = "ssm_activation"
}

#Create REST method
resource "aws_api_gateway_method" "r_ssm_activation_post" {
  rest_api_id   = aws_api_gateway_rest_api.r_rest_api_gateway_private.id
  resource_id   = aws_api_gateway_resource.r_resource_ssm_activation.id
  http_method   = "POST"
  authorization = "NONE"
}

#Integrate lambda function
resource "aws_api_gateway_integration" "r_ssm_activation_integration" {
  rest_api_id             = aws_api_gateway_rest_api.r_rest_api_gateway_private.id
  resource_id             = aws_api_gateway_resource.r_resource_ssm_activation.id
  http_method             = aws_api_gateway_method.r_ssm_activation_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.r_lambda_function_ssm_get_activation_codes.invoke_arn
}

#api gateway integration response
resource "aws_api_gateway_method_response" "r_ssm_activation_response_200" {
  rest_api_id = aws_api_gateway_rest_api.r_rest_api_gateway_private.id
  resource_id = aws_api_gateway_resource.r_resource_ssm_activation.id
  http_method = aws_api_gateway_method.r_ssm_activation_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "r_ssm_activation_response_200_integration" {
  rest_api_id = aws_api_gateway_rest_api.r_rest_api_gateway_private.id
  resource_id = aws_api_gateway_resource.r_resource_ssm_activation.id
  http_method = aws_api_gateway_method.r_ssm_activation_post.http_method
  status_code = aws_api_gateway_method_response.r_ssm_activation_response_200.status_code

  # Transforms the backend JSON response to XML
  # response_templates = {
  #   "application/xml" = <<EOF
  #     #set($inputRoot = $input.path('$'))
  #     <?xml version="1.0" encoding="UTF-8"?>
  #     <message>
  #       $inputRoot.body
  #     </message>
  #   EOF
  # }
  depends_on = [aws_api_gateway_integration.r_ssm_activation_integration]
}

resource "aws_api_gateway_rest_api_policy" "r_ssm_activation_api_gateway_policy" {
  rest_api_id = aws_api_gateway_rest_api.r_rest_api_gateway_private.id
  policy      = data.aws_iam_policy_document.d_ssm_api_gateway_resource_policy.json
}



resource "aws_api_gateway_deployment" "r_ssm_activation_response_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.r_rest_api_gateway_private.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.r_resource_ssm_activation.id,
      aws_api_gateway_method.r_ssm_activation_post.id,
      aws_api_gateway_integration.r_ssm_activation_integration.id,
      data.aws_iam_policy_document.d_ssm_api_gateway_resource_policy,

    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "r_ssm_activation_stage_prod" {
  deployment_id = aws_api_gateway_deployment.r_ssm_activation_response_api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.r_rest_api_gateway_private.id
  stage_name    = "prod"
}
