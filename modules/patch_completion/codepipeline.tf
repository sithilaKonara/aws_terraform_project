resource "aws_codecommit_repository" "r_ssm_patch_completion_repo" {
  repository_name = var.v_patch_completion_function_name
  description     = "Patch Completion Lambda function source code"
}


resource "aws_codebuild_project" "r_codebuild_project_ssm_patch_completion" {
  name           = var.v_patch_completion_function_name
  description    = "patch_completion build project"
  build_timeout  = 60
  queued_timeout = 480
  badge_enabled  = true
  service_role   = aws_iam_role.r_cbp_patch_completion_code_build_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.v_patch_completion_region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.v_patch_completion_account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = lower("${var.v_patch_completion_function_name}")
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.r_ssm_patch_completion_repo.clone_url_http
    git_clone_depth = 1
  }
  source_version = "refs/heads/master"
}

resource "aws_codepipeline" "r_code_pipeline_ssm_patch_completion" {
  name     = var.v_patch_completion_function_name
  role_arn = aws_iam_role.r_role_CodepipelineServiceRole-PatchCompletion.arn
  artifact_store {
    type     = "S3"
    location = var.v_patch_completion_codebuildArtifactStore.bucket #### > Check whether this is the correct bucket < ####

  }
  stage {
    name = "Source"
    action {
      category         = "Source"
      owner            = "AWS"
      name             = "Source"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        RepositoryName = var.v_patch_completion_function_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"
    action {
      category         = "Build"
      owner            = "AWS"
      name             = "Build"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      configuration = {
        ProjectName = aws_codebuild_project.r_codebuild_project_ssm_patch_completion.name
      }
    }
  }

}
