
# IAM role for tags_handler code build
resource "aws_iam_role" "r_iam_role_code_build_ssm_mi_deregistration" {
  name                 = "${var.v_mi_deregistration_function_name}-lambda-role-${var.v_mi_deregistration_region}-${var.v_mi_deregistration_account_id}"
  description          = "Service role used in trust relationship with CodeBuild "
  path                 = "/"
  max_session_duration = 3600
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  ]
  inline_policy {
    name   = "ExecutionPolicy"
    policy = data.aws_iam_policy_document.d_policy_document_codebuild_ssm_mi_deregistration.json
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
