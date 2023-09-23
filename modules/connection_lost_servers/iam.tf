# IAM policy connection_lost_servers code build
resource "aws_iam_policy" "r_iam_policy_ssm_connection_lost_servers" {
  name        = "${var.v_connection_lost_servers_function_name}-codebuild-policy-${var.v_connection_lost_servers_aws_region}-${var.v_connection_lost_servers_aws_account}"
  description = "Policy used in trust relationship with CodeBuild"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_policy_document_codebuild_ssm_connection_lost_servers.json
}

# IAM role for connection_lost_servers code build
resource "aws_iam_role" "r_iam_role_code_build_ssm_connection_lost_servers" {
  name                 = "${var.v_connection_lost_servers_function_name}-cb-role-${var.v_connection_lost_servers_aws_region}-${var.v_connection_lost_servers_aws_account}"
  description          = "Service role used in trust relationship with CodeBuild "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_iam_policy_ssm_connection_lost_servers.arn]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  depends_on = [
    aws_iam_policy.r_iam_policy_ssm_connection_lost_servers
  ]
}

# IAM policy connection_lost_servers code pipleine
resource "aws_iam_policy" "r_iam_policy_code_pipeline_ssm_connection_lost_servers" {
  name        = "${var.v_connection_lost_servers_function_name}-codepipeline-policy-${var.v_connection_lost_servers_aws_region}-${var.v_connection_lost_servers_aws_account}"
  description = "Policy used in trust relationship with CodePipeline"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_policy_document_code_pipeline_ssm_connection_lost_servers.json
}

# IAM role connection_lost_servers codepipeline
resource "aws_iam_role" "r_iam_role_codepipeline_ssm_connection_lost_servers" {
  name                 = "${var.v_connection_lost_servers_function_name}-cp-role-${var.v_connection_lost_servers_aws_region}-${var.v_connection_lost_servers_aws_account}"
  description          = "Service role used in trust relationship with CodePipeline "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_iam_policy_code_pipeline_ssm_connection_lost_servers.arn]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  depends_on = [
    aws_iam_policy.r_iam_policy_code_pipeline_ssm_connection_lost_servers
  ]
}
