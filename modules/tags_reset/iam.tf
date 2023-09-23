# IAM policy ssm-tags reset
resource "aws_iam_policy" "r_policy_ssm_tagsReset" {
  name        = "ssm-policy-tags_reset-${var.v_aws_account}"
  description = "Policy used in trust relationship with CodePipeline"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_ssm_tags.json
}

# IAM role ssm-tags reset
resource "aws_iam_role" "r_role_CodepipelineServiceRole-TagReset" {
  name                 = "ssm-codePipelineServiceRole-tagsReset-${var.v_aws_account}"
  description          = "Service role used in trust relationship with CodePipeline "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_policy_ssm_tagsReset.arn]
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

# IAM policy for ssm-tags_reset code build
resource "aws_iam_policy" "r_ssm_tagsResetcodebuild_policy" {
  name        = "${var.v_function_name}-codeBuildServicePolicy-${var.v_aws_account}"
  description = "Policy used in trust relationship with CodeBuild"
  path        = "/service-role/"
  policy      = data.aws_iam_policy_document.d_pd_ssm_tagsResetcodeBuild_policy.json
}

# IAM role for ssm-tags_reset code build
resource "aws_iam_role" "r_role_CodebuilServiceRole-TagReset" {
  name                 = "${var.v_function_name}-codeBuildServiceRole-${var.v_aws_account}"
  description          = "Service role used in trust relationship with CodeBuild "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_ssm_tagsResetcodebuild_policy.arn]
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

#Create ECS task execution role
resource "aws_iam_role" "r_ssm_ecsTasExecutionRole" {
  name                 = "ssm-ecsTaskExecutionRole-${var.v_aws_account}"
  description          = "Provides access to other AWS service resources that are required to run Amazon ECS tasks"
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  inline_policy {
    name   = "ssm-ecsLogCreation"
    policy = data.aws_iam_policy_document.d_pd_ECS_log_group_creation.json
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

#Create ssm_tags_reset_ecsTaskRole
resource "aws_iam_role" "r_ssm_tagsReset_ecsTaskRole" {
  name                 = "${var.v_function_name}-ecsTaskRole-${var.v_aws_account}"
  description          = "Allows ECS tasks to call AWS services on your behalf."
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  ]

  inline_policy {
    name   = "ssm-executionPolicy"
    policy = data.aws_iam_policy_document.d_pd_ExecutionPolicy_ssm_tagsReset_ecsTaskRole.json
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

##################
resource "aws_iam_role" "r_ssm_lambdaECS" {
  name                 = "ssm-lambda_ecs"
  description          = " "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]
  inline_policy {
    name   = "ssm-executionPolicy"
    policy = data.aws_iam_policy_document.d_pd_ssm_executionPolicyLambdaECS.json
  }

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ssm-lambda_logging" {
  name        = "ssm-lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.r_ssm_lambdaECS.name
  policy_arn = aws_iam_policy.ssm-lambda_logging.arn
}