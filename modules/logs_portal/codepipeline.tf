#Create logs portal codecommit repository
resource "aws_codecommit_repository" "r_codecommit_repository_ssm_logs_portal" {
  repository_name = var.v_logs_portal_function_name
  description     = "${var.v_logs_portal_function_name} source code repository"
}


#Create logs_portal code-build project
resource "aws_codebuild_project" "r_codebuild_project_ssm_logs_portal" {
  name          = var.v_logs_portal_function_name
  description   = "${var.v_logs_portal_function_name} build project"
  build_timeout = "60"
  service_role  = aws_iam_role.r_iam_role_code_build_ssm_logs_portal.arn
  #### > need to build IAM role < ####
  badge_enabled = false

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type = "CODEPIPELINE" # updated 26/09/2022
    # location        = aws_codecommit_repository.r_codecommit_repository_ssm_logs_portal.clone_url_http    # This commented as type set to "CODEPIPELINE" 
    git_clone_depth = 0 # updated 26/09/2022
  }

  # source_version = "refs/heads/master"  # updated 26/09/2022

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true


    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.v_logs_portal_region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.v_logs_portal_account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = lower("${aws_codecommit_repository.r_codecommit_repository_ssm_logs_portal.repository_name}")
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
    aws_iam_role.r_iam_role_code_build_ssm_logs_portal,
    aws_codecommit_repository.r_codecommit_repository_ssm_logs_portal
  ]
}


# Create code deploy app for logs portal
resource "aws_codedeploy_app" "r_codedeploy_app_logs_portal" {
  compute_platform = "ECS"
  name             = "AppECS-${var.v_logs_portal_function_name}"
}

# Create code deployment group for logs portal
resource "aws_codedeploy_deployment_group" "r_codedeploy_group_logs_portal" {
  app_name               = aws_codedeploy_app.r_codedeploy_app_logs_portal.name
  deployment_group_name  = "${var.v_logs_portal_function_name}-DG"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.r_iam_role_codedeploy_deployment_group_logs_portal.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  #### > Configure Load balancer < ####
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.r_alb_ssm_listener.arn]
      }
      target_group {
        name = aws_lb_target_group.r_alb_target_group_ssm_logs_portal_80_blue.name
      }
      target_group {
        name = aws_lb_target_group.r_alb_target_group_ssm_logs_portal_80_green.name
      }
    }
  }

  ecs_service {
    #### > Check whether we can get the ECS cluester name correctly < ####
    cluster_name = var.v_logs_portal_ecs_cluster_name
    #### > Construct ECS service  < ####
    service_name = aws_ecs_service.r_ecs_service_ssm_logs_portal.name
  }

  #### > Check below configuration needed or not < ####
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
}

#Create logs portal pipeline
resource "aws_codepipeline" "r_codepipeline_ssm_logs_portal" {
  name     = var.v_logs_portal_function_name
  role_arn = aws_iam_role.r_iam_role_codepipeline_ssm_logs_portal.arn

  #### > Create IAM role < ####

  artifact_store {
    location = var.v_logs_portal_codeBuildArtifactStore.bucket
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
        RepositoryName = aws_codecommit_repository.r_codecommit_repository_ssm_logs_portal.repository_name
        BranchName     = "master"
      }
    }
    action {
      name             = "Source_Config"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceConfigArtifact"]
      configuration = {
        RepositoryName = aws_codecommit_repository.r_codecommit_repository_ssm_logs_portal.repository_name
        BranchName     = "configs"
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
      output_artifacts = ["AppImage"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.r_codebuild_project_ssm_logs_portal.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["AppImage", "SourceConfigArtifact"]
      version         = "1"

      configuration = {
        # Ref: https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-ECSbluegreen.html
        ApplicationName                = "${aws_codedeploy_app.r_codedeploy_app_logs_portal.name}"
        DeploymentGroupName            = "${var.v_logs_portal_function_name}-DG" #"SSM-logs-portal-DG" #"${aws_codedeploy_deployment_group.r_codedeploy_group_logs_portal.id}"
        TaskDefinitionTemplateArtifact = "SourceConfigArtifact"
        AppSpecTemplateArtifact        = "SourceConfigArtifact"
        AppSpecTemplatePath            = "appspec.yaml"
        Image1ArtifactName             = "AppImage"
        Image1ContainerName            = "IMAGE1_NAME"
        TaskDefinitionTemplatePath     = "taskdef.json"
        #   # ActionMode     = "REPLACE_ON_FAILURE"
        #   # Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        #   # OutputFileName = "taskdef.json"
        #   StackName      = "AppECS-SSM-SSM-LOGS-PORTAL"
        #   # TemplatePath   = "build_output::sam-templated.yaml"
      }
    }
  }
  depends_on = [
    aws_codebuild_project.r_codebuild_project_ssm_logs_portal,
    aws_codecommit_repository.r_codecommit_repository_ssm_logs_portal,
    aws_iam_role.r_iam_role_codepipeline_ssm_logs_portal
  ]
}
