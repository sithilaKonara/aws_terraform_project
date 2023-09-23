data "aws_iam_policy_document" "d_pd_TaskAssumePolicy_ecs_patch_completion" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "d_pd_ExecutionPolicy_ssm_PatchCompletion_ecsTaskRole" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]

  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [var.v_patch_completion_kms_key_arn]
  }

  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }

  #### > Need to configure email for email@abccompany.com < ####
  statement {
    actions = ["ses:SendEmail"]
    resources = [var.v_patch_completion_send_email_id_arn, var.v_patch_completion_email_domain_arn]
  }
}

## Create policy document for Patch Completion Code Build 
data "aws_iam_policy_document" "d_pd_codeBuild_patch_completion_assume_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "d_pd_codeBuild_patch_completion" {
  statement {
    effect = "Allow"
    resources = [aws_cloudwatch_log_group.r_ssm_patch_completion_log_group.arn,
    "${aws_cloudwatch_log_group.r_ssm_patch_completion_log_group.arn}:*"]
    actions = ["logs:CreateLogGroup",
      "logs:CreateLogStream",
    "logs:PutLogEvents"]
  }
  statement {
    effect    = "Allow"
    resources = ["${var.v_patch_completion_codebuildArtifactStore.arn}*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
  }

  statement {
    effect    = "Allow"
    resources = [aws_codecommit_repository.r_ssm_patch_completion_repo.arn]
    actions   = ["codecommit:GitPull"]
  }

  #### > Here we have cerculer dependancy, Policy refer code build arn and code build required this policy to build < ####
  statement {
    effect    = "Allow"
    resources = ["arn:aws:codebuild:${var.v_patch_completion_region}:${var.v_patch_completion_account_id}:report-group/${var.v_patch_completion_function_name}-*"]
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
  }
}


data "aws_iam_policy_document" "d_pd_codePipeline_patch_completion_assume_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "d_pd_codePipeline_patch_completion" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]

    #### > Check whether this condition works as expected < ####
    condition {
      test = "StringEqualsIfExists"
      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
      variable = "iam:PassedToService"
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "opsworks:CreateDeployment",
      "opsworks:DescribeApps",
      "opsworks:DescribeCommands",
      "opsworks:DescribeDeployments",
      "opsworks:DescribeInstances",
      "opsworks:DescribeStacks",
      "opsworks:UpdateApp",
      "opsworks:UpdateStack"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "devicefarm:ListProjects",
      "devicefarm:ListDevicePools",
      "devicefarm:GetRun",
      "devicefarm:GetUpload",
      "devicefarm:CreateUpload",
      "devicefarm:ScheduleRun"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:CreateProvisioningArtifact",
      "servicecatalog:DescribeProvisioningArtifact",
      "servicecatalog:DeleteProvisioningArtifact",
      "servicecatalog:UpdateProduct"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudformation:ValidateTemplate"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeImages"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "states:DescribeExecution",
      "states:DescribeStateMachine",
      "states:StartExecution"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment"
    ]
    resources = ["*"]
  }
}
