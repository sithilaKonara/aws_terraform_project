#Create connection_lost_servers codecommit repository
resource "aws_codecommit_repository" "r_codecommit_repository_ssm_connection_lost_servers" {
  repository_name = var.v_connection_lost_servers_function_name
  description     = "${var.v_connection_lost_servers_function_name} source code repository"
}

#Create connection_lost_servers code-build project
resource "aws_codebuild_project" "r_codebuild_project_ssm_connection_lost_servers" {
  name          = var.v_connection_lost_servers_function_name
  description   = "${var.v_connection_lost_servers_function_name} build project"
  build_timeout = "60"
  service_role  = aws_iam_role.r_iam_role_code_build_ssm_connection_lost_servers.arn
  badge_enabled = true

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.r_codecommit_repository_ssm_connection_lost_servers.clone_url_http
    git_clone_depth = 1
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
      value = var.v_connection_lost_servers_aws_region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.v_connection_lost_servers_aws_account
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_codecommit_repository.r_codecommit_repository_ssm_connection_lost_servers.repository_name
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
  depends_on = [
    aws_iam_role.r_iam_role_code_build_ssm_connection_lost_servers,
    aws_codecommit_repository.r_codecommit_repository_ssm_connection_lost_servers
  ]
}

#Create connection_lost_servers pipeline
resource "aws_codepipeline" "r_codepipeline_ssm_connection_lost_servers" {
  name     = var.v_connection_lost_servers_function_name
  role_arn = aws_iam_role.r_iam_role_codepipeline_ssm_connection_lost_servers.arn

  artifact_store {
    location = var.v_connection_lost_servers_codepipeline_artifact_s3_bkt.bucket
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
        RepositoryName = aws_codecommit_repository.r_codecommit_repository_ssm_connection_lost_servers.repository_id
        BranchName     = "main"
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
        ProjectName = aws_codebuild_project.r_codebuild_project_ssm_connection_lost_servers.name
      }
    }
  }
  depends_on = [
    aws_codebuild_project.r_codebuild_project_ssm_connection_lost_servers,
    aws_codecommit_repository.r_codecommit_repository_ssm_connection_lost_servers,
    aws_iam_role.r_iam_role_codepipeline_ssm_connection_lost_servers
  ]
}
