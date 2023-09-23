# IAM role for patch_failure_report code build
resource "aws_iam_role" "r_iam_role_code_build_ssm_patch_failure_report" {
  name                 = "${var.v_patch_failure_report_function_name}-lambda-${var.v_patch_failure_report_region}-${var.v_patch_failure_report_account_id}"
  description          = "Service role used in trust relationship with CodeBuild "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
  ]
  inline_policy {
    name   = "ExecutionPolicy"
    policy = data.aws_iam_policy_document.d_policy_document_codebuild_ssm_patch_failure_report.json
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
