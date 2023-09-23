#Create document policy for ms_teams_notifications lambda IAM role
data "aws_iam_policy_document" "d_policy_document_codebuild_ssm_ms_teams_notifications" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.v_ms_teams_notifications_kms_key_arn]
  }
}
