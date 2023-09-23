# IAM role for tags_handler code build
resource "aws_iam_role" "r_iam_role_code_build_ssm_s3_cleanup" {
  name                 = "${var.v_s3_cleanup_function_name}-lambda-role-${var.v_s3_cleanup_region}-${var.v_s3_cleanup_account_id}"
  description          = "Service role used in trust relationship with CodeBuild "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
  ]
  inline_policy {
    name   = "ExecutionPolicy"
    policy = data.aws_iam_policy_document.d_policy_document_codebuild_ssm_s3_cleanup.json
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
