data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "r_ecs_patch_completion_role" {
  name = "ecsTaskRolePatchCompletion"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
  "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]

  inline_policy {
    name   = "ExecutionPolicy"
    policy = data.aws_iam_policy_document.d_pd_ExecutionPolicy_ssm_PatchCompletion_ecsTaskRole.json
  }
  assume_role_policy = data.aws_iam_policy_document.d_pd_TaskAssumePolicy_ecs_patch_completion.json
}

resource "aws_iam_role" "r_cbp_patch_completion_code_build_role" {
  name               = "codebuild-patch_completion-service-role"
  assume_role_policy = data.aws_iam_policy_document.d_pd_codeBuild_patch_completion_assume_policy.json
  inline_policy {
    # name   = "CodeBuildBasePolicy-patch_completion-${var.v_patch_completion_reagion.current}"
    name   = "CodeBuildBasePolicy-patch_completion"
    policy = data.aws_iam_policy_document.d_pd_codeBuild_patch_completion.json
  }
}

# resource "aws_iam_policy" "r_ecs_patch_completion_code_build_policy" {
#   name = "CodeBuildBasePolicy-patch_completion-${data.aws_region.current}"
#   path = "/"
#   description = "Policy used in trush relationship with code build"
#   policy = data.aws_iam_policy_document.d_pd_codeBuild_patch_completion
#   #### > need to create the policy document < ####

# }


# resource "aws_iam_role" "r_cbp_patch_completion_code_pipeline_role" {
#   name               = "CodePipelineServiceRole-${var.v_patch_completion_reagion}-${var.v_patch_completion_function_name}"
#   assume_role_policy = data.aws_iam_policy_document.d_pd_codeBuild_patch_completion_assume_policy.json
#   inline_policy {
#     name   = "CodePipelineServiceRole-${var.v_patch_completion_reagion}-${var.v_patch_completion_function_name}"
#     policy = data.aws_iam_policy_document.d_pd_codePipeline_patch_completion.json
#   }

# }


# IAM role ssm-tags reset
resource "aws_iam_role" "r_role_CodepipelineServiceRole-PatchCompletion" {
  name                 = "ssm-codePipelineServiceRole-${var.v_patch_completion_function_name}-${var.v_patch_completion_account_id}"
  description          = "Service role used in trust relationship with CodePipeline "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_policy_ssm_patchCompletion.arn]
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

# IAM policy ssm-tags reset
resource "aws_iam_policy" "r_policy_ssm_patchCompletion" {
  name        = "ssm-policy-${var.v_patch_completion_function_name}-${var.v_patch_completion_account_id}"
  description = "Policy used in trust relationship with CodePipeline"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_pd_codePipeline_patch_completion.json
}