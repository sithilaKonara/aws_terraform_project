#Create document policy for patch report lambda policy
data "aws_iam_policy_document" "d_policy_document_codebuild_ssm_patch_failure_report" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.r_cloudwatch_log_group_lambda_ssm_patch_failure_report.arn,
      "${aws_cloudwatch_log_group.r_cloudwatch_log_group_lambda_ssm_patch_failure_report.arn}:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
    ]
    resources = [
      "${var.v_patch_failure_report_domain_ses_arn}",
      "${var.v_patch_failure_report_email_ses_arn}"
    ]
  }
}
