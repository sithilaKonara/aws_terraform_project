#Creating Athena Workgroup
resource "aws_athena_workgroup" "r_athena_workgroup" {
  name        = var.v_system_manager_athena_workgroup["athena_workgroup"]
  description = "Systems Manager Managed Instance Workgroup"
  state       = "ENABLED"

  configuration {
    publish_cloudwatch_metrics_enabled = true
    enforce_workgroup_configuration    = true
    requester_pays_enabled             = true
    bytes_scanned_cutoff_per_query     = 20000000
    #Unable to set Query engine update status to Manual
    result_configuration {
      output_location = "s3://${aws_s3_bucket.r_athena_query_result.bucket}"
      #NEED TO ADD KMS KEY ARN
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.r_cmk.arn
      }
    }
  }
  force_destroy = true
}
