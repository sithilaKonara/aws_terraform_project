# IAM policy email_handler code build
resource "aws_iam_policy" "r_iam_policy_ssm_email_handler" {
  name        = "${var.v_email_handler_function_name}-codebuild-policy-${var.v_email_handler_aws_region}-${var.v_email_handler_aws_account}"
  description = "Policy used in trust relationship with CodeBuild"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_policy_document_codebuild_ssm_email_handler.json
}

# IAM role for tags_handler code build
resource "aws_iam_role" "r_iam_role_code_build_ssm_email_handler" {
  name                 = "${var.v_email_handler_function_name}-codebuild-role-${var.v_email_handler_aws_region}-${var.v_email_handler_aws_account}"
  description          = "Service role used in trust relationship with CodeBuild "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_iam_policy_ssm_email_handler.arn]
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
    aws_iam_policy.r_iam_policy_ssm_email_handler
  ]
}

# IAM policy email_handler code pipleine
resource "aws_iam_policy" "r_iam_policy_code_pipeline_ssm_email_handler" {
  name        = "${var.v_email_handler_function_name}-codepipeline-policy-${var.v_email_handler_aws_region}-${var.v_email_handler_aws_account}"
  description = "Policy used in trust relationship with CodePipeline"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_policy_document_code_pipeline_ssm_email_handler.json
}

# IAM role email_handler codepipeline
resource "aws_iam_role" "r_iam_role_codepipeline_ssm_email_handler" {
  name                 = "${var.v_email_handler_function_name}-codepipeline-role-${var.v_email_handler_aws_region}-${var.v_email_handler_aws_account}"
  description          = "Service role used in trust relationship with CodePipeline "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_iam_policy_code_pipeline_ssm_email_handler.arn]
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
    aws_iam_policy.r_iam_policy_code_pipeline_ssm_email_handler
  ]
}

# IAM role email_handler ecs task role
resource "aws_iam_role" "r_iam_role_ecs_task_ssm_email_handler" {
  name                 = "${var.v_email_handler_function_name}-ecs-task-role-${var.v_email_handler_aws_region}-${var.v_email_handler_aws_account}"
  description          = "Service role used in trust relationship with ECS task definition "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonSSMFullAccess"]
  inline_policy {
    name   = "ExecutionPolicy"
    policy = data.aws_iam_policy_document.d_pd_ExecutionPolicy_ssm_ssm_email_handler_ecsTaskRole.json
  }
  inline_policy {
    name   = "InvokeLambda"
    policy = data.aws_iam_policy_document.d_ssm_invokelambda_email_handler.json
  }
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
