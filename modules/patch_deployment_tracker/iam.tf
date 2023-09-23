resource "aws_iam_policy" "r_ssm_QSAnonymousEmbedPolicy" {
  name        = "ssm-QSAnonymousEmbedPolicy-${var.v_aws_account}"
  description = "Grants Amazon QuickSight embedded url get permission to Amazon lambda function"
  path        = "/"
  policy      = data.aws_iam_policy_document.d_ssm_QSAnonymousEmbedPolicyDocument.json
}

resource "aws_iam_role" "r_role_ssm_QSAnonymousEmbedRole" {
  name                 = "ssm-QSAnonymousEmbedRole-${var.v_aws_account}"
  description          = "Allows Lambda to call AWS services on your behalf"
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns  = [aws_iam_policy.r_ssm_QSAnonymousEmbedPolicy.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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