# Create task role for SSM Reporting ECS task execution
resource "aws_iam_role" "r_ecs_task_store_patch_data_role" {
  name                = "ecsTaskRoleStorePatchData"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", "arn:aws:iam::aws:policy/AmazonSSMFullAccess"]

  inline_policy {
    name = "ExecutionPolicy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : ["sts:AssumeRole"],
          "Resource" : "*",
          "Effect" : "Allow"
        }
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

}

# Create SSM Code build in pipeline
resource "aws_iam_role" "r_code_build_service_role_ssm-reporting" {
  name                 = "codebuild-ssm_reporting-service-role"
  description          = "Service role used in trust relationship with CodeBuild"
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_policy_ssm_reporting_codebuild.arn]
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

}

# Attach policy document for "r_code_build_service_role_ssm-reporting" role
resource "aws_iam_policy" "r_policy_ssm_reporting_codebuild" {
  name        = "codebuild-ssm_reporting-service-policy"
  path        = "/"
  description = "Policy used in trust relationship with code build"
  policy      = data.aws_iam_policy_document.d_pd_codeBuild_reporting.json

}

# Create role for code pipeline
resource "aws_iam_role" "r_code_pipeline_service_role_ssm-reporting" {
  name                 = "AWSCodePipelineServiceRole-${var.v_aws_region}-${var.v_function_name}"
  description          = "Service role used in trush relationship with CodePipeline"
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_policy_ssm_reporting_codepipeline.arn]

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
}

resource "aws_iam_policy" "r_policy_ssm_reporting_codepipeline" {
  name        = "codepipeline-${var.v_function_name}-service-policy"
  path        = "/"
  description = "Policy used in trust relationship with code build"
  policy      = data.aws_iam_policy_document.d_pd_codePipeline_reporting.json

}