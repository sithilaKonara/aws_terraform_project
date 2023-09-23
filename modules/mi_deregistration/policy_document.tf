#Create document policy for mi_deregistration lambda IAM role
data "aws_iam_policy_document" "d_policy_document_codebuild_ssm_mi_deregistration" {
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
    resources = [var.v_mi_deregistration_kms_key_arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [var.v_mi_deregistration_ssm_sns_arn]
  }
}
