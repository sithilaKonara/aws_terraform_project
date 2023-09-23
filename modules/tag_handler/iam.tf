# IAM policy tag_handler code build
resource "aws_iam_policy" "r_iam_policy_ssm_tag_handler" {
  name        = "${var.v_tag_handler_function_name}-codebuild-policy-${var.v_tag_handler_aws_region}-${var.v_tag_handler_aws_account}"
  description = "Policy used in trust relationship with CodeBuild"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_policy_document_codebuild_ssm_tag_handler.json
}

# IAM role for tags_handler code build
resource "aws_iam_role" "r_iam_role_code_build_ssm_tag_handler" {
  name                 = "${var.v_tag_handler_function_name}-codebuild-role-${var.v_tag_handler_aws_region}-${var.v_tag_handler_aws_account}"
  description          = "Service role used in trust relationship with CodeBuild "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_iam_policy_ssm_tag_handler.arn]
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
    aws_iam_policy.r_iam_policy_ssm_tag_handler
  ]
}

# IAM policy tag_handler code pipleine
resource "aws_iam_policy" "r_iam_policy_code_pipeline_ssm_tag_handler" {
  name        = "${var.v_tag_handler_function_name}-codepipeline-policy-${var.v_tag_handler_aws_region}-${var.v_tag_handler_aws_account}"
  description = "Policy used in trust relationship with CodePipeline"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_policy_document_code_pipeline_ssm_tags_handler.json
}

# IAM role tag_handler codepipeline
resource "aws_iam_role" "r_iam_role_codepipeline_ssm_tag_handler" {
  name                 = "${var.v_tag_handler_function_name}-codepipeline-role-${var.v_tag_handler_aws_region}-${var.v_tag_handler_aws_account}"
  description          = "Service role used in trust relationship with CodePipeline "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_iam_policy_code_pipeline_ssm_tag_handler.arn]
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
    aws_iam_policy.r_iam_policy_code_pipeline_ssm_tag_handler
  ]
}