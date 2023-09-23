data "aws_iam_policy_document" "d_ssm_QSAnonymousEmbedPolicyDocument" {
  statement {
    effect = "Allow"
    actions = [
      "quicksight:GetDashboardEmbedUrl",
      "quickSight:GetAnonymousUserEmbedUrl"
    ]
    resources = ["arn:aws:quicksight:${var.v_aws_region}:${var.v_aws_account}:dashboard/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}
