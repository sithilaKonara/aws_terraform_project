resource "aws_iam_role" "r_iam_role_code_build_ssm_logs_portal" {
  name               = join("-", ["codebuild", "${var.v_logs_portal_function_name}", "service-role"])
  assume_role_policy = data.aws_iam_policy_document.d_pd_codebuild_assume_ssm_logs_portal.json
  #### > need to build the assume role policy < ####
  inline_policy {
    name   = join("-", ["CodeBuildBasePolicy", "${var.v_logs_portal_function_name}", "${var.v_logs_portal_region}"])
    policy = data.aws_iam_policy_document.d_pd_codebuild_ssm_logs_portal.json
    # policy = aws_iam_policy.r_iam_policy_code_build_ssm_logs_portal.arn

  }

  inline_policy {
    name   = "CodeDeployS3Access"
    policy = data.aws_iam_policy_document.d_pd_deploy_ssm_logs_portal.json
    # policy = aws_iam_policy.r_iam_policy_code_deploy_ssm_logs_portal.arn
  }
  #### > need to build inline policy < ####
}


# resource "aws_iam_policy" "r_iam_policy_code_build_ssm_logs_portal" {
#   name        = join("-", ["CodeBuildBasePolicy", "${var.v_logs_portal_function_name}", "${var.v_logs_portal_reagion}"])
#   path        = "/"
#   description = "Policy used in trust relationship with CodeBuild"
#   policy      = data.aws_iam_policy_document.d_pd_codebuild_ssm_logs_portal.json

# }

# resource "aws_iam_policy" "r_iam_policy_code_deploy_ssm_logs_portal" {
#   name   = "CodeDeployS3Access"
#   path   = "/"
#   policy = data.aws_iam_policy_document.d_pd_deploy_ssm_logs_portal.json
# }

resource "aws_iam_role" "r_iam_role_codepipeline_ssm_logs_portal" {
  name               = join("-", ["AWSCodePipelineServiceRole", "${var.v_logs_portal_region}", "${var.v_logs_portal_function_name}"])
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.d_pd_codepipeline_assume_role_policy.json
  inline_policy {
    name   = join("-", ["AWSCodePipelineServiceRole", "${var.v_logs_portal_region}", "${var.v_logs_portal_function_name}"])
    policy = data.aws_iam_policy_document.d_pd_codepipeline_ssm_logs_portal.json
  }
}


# Role for code deploy deployment group
resource "aws_iam_role" "r_iam_role_codedeploy_deployment_group_logs_portal" {
  name                = "ecsCodeDeployRole"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"]
  assume_role_policy  = data.aws_iam_policy_document.d_pd_code_deployment_group_assume_role_policy.json
}

resource "aws_iam_policy" "r_ssm_logs_portal_manage_policy" {
  name   = "LogsPortalManagedPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.d_pd_task_role_ssm_logs_portal.json
}

resource "aws_iam_role" "r_iam_role_ecs_task_role" {
  name                 = "${var.v_logs_portal_function_name}-ecsTaskRole-${var.v_logs_portal_account_id}"
  description          = "Allows ECS tasks to call AWS services on your behalf."
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_ssm_logs_portal_manage_policy.arn]
  inline_policy {
    name   = "ssm-executionPolicy"
    policy = data.aws_iam_policy_document.d_pd_task_role_ssm_logs_portal_inline_policy.json
  }

  assume_role_policy = data.aws_iam_policy_document.d_pd_task_role_assume_role_policy.json

}

resource "aws_iam_policy" "r_iam_policy_ssm_get_activation_codes" {
  name   = "${var.v_logs_portal_get_activation_codes_function_name}_lambda-${var.v_logs_portal_account_id}"
  path   = "/"
  policy = data.aws_iam_policy_document.d_lambda_ssm_get_activation_codes.json
}

resource "aws_iam_role" "r_iam_role_lambda_get_activation_codes" {
  name                 = "${var.v_logs_portal_get_activation_codes_function_name}-ecsTaskRole-${var.v_logs_portal_account_id}"
  description          = "Allows Lambda function to call AWS services on your behalf."
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_iam_policy_ssm_get_activation_codes.arn]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "r_iam_role_api_gateway_cloudwatch_log" {
  name                 = "SSM-api_gateway_cloudwatch_log-${var.v_logs_portal_account_id}"
  description          = "Allows API gateway to log cloud watch logs."
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "apigateway.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}



