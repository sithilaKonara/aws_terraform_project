#Create SSM Reporting codecommit repo
resource "aws_codecommit_repository" "r_ssm_reporting_repo" {
  repository_name = var.v_function_name
  description     = "ssm-reporting source code repository"
}

#Create code build project for SSM Reporting. 
resource "aws_codebuild_project" "r_cbp_ssm_reporting" {
  name          = var.v_function_name
  description   = "ssm_reporting build project"
  build_timeout = "60"
  badge_enabled = true
  service_role  = aws_iam_role.r_code_build_service_role_ssm-reporting.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.r_ssm_reporting_repo.clone_url_http
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = false
    }
  }

  source_version = "refs/heads/master"

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true


    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.v_aws_region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.v_aws_account
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = lower("${var.v_function_name}")
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}

resource "aws_codepipeline" "r_cbp_ssm_reporting" {
  name     = var.v_function_name
  role_arn = aws_iam_role.r_code_pipeline_service_role_ssm-reporting.arn
  artifact_store {
    #   location = "${var.v_codebuildArtifactStore["s3_store_artifacts_arn"]}"
    location = var.v_codebuildArtifactStore.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        RepositoryName = var.v_function_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.r_cbp_ssm_reporting.name
      }
    }
  }
}
