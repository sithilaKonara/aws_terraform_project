#Create document policy for hybrid_activation lambda IAM role
data "aws_iam_policy_document" "d_policy_document_codebuild_ssm_hybrid_activation" {
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
    resources = [var.v_hybrid_activation_kms_key_arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [var.v_hybrid_activation_ssm_sns_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "iam:GetRole"
    ]
    resources = [var.v_hybrid_activation_automation_administration_iam_role["ssm-automationAdministrationRole_arn"]]
  }
}
