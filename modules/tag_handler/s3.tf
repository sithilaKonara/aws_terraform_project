#Create ssm tag instance bucket
resource "aws_s3_bucket" "r_s3_bucket_ssm_tag_handler" {
  bucket        = "${var.v_tag_handler_s3_bkt}-${var.v_tag_handler_aws_region}-${var.v_tag_handler_aws_account}"
  force_destroy = true
}

#Enable ssm tag instance bucket vesioning
resource "aws_s3_bucket_versioning" "r_s3_bucket_versioning_ssm_tag_handler" {
  bucket = aws_s3_bucket.r_s3_bucket_ssm_tag_handler.id
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [
    aws_s3_bucket.r_s3_bucket_ssm_tag_handler
  ]
}

#Enable ssm tag instance bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "r_s3_bucket_server_side_encryption_configuration_ssm__tag_handler" {
  bucket = aws_s3_bucket.r_s3_bucket_ssm_tag_handler.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.v_tag_handler_kms_key
      sse_algorithm     = "aws:kms"
    }
  }
  depends_on = [
    aws_s3_bucket.r_s3_bucket_ssm_tag_handler
  ]
}

#Enable ssm tag instance bucket event notification
# Moved configuration to mi_deregistration

# resource "aws_s3_bucket_notification" "r_s3_bucket_notification_ssm_tag_handler" {
#   bucket = aws_s3_bucket.r_s3_bucket_ssm_tag_handler.id

#   lambda_function {
#     id                  = "tag-handler_ecs notification"
#     lambda_function_arn = aws_lambda_function.r_lambda_function_ssm_tag_handler_ecs.arn
#     events              = ["s3:ObjectCreated:Put"]
#     filter_prefix       = "uploads"
#   }
#   depends_on = [
#     aws_lambda_function.r_lambda_function_ssm_tag_handler_ecs
#   ]
# }

#Block S3 bucket public access
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.r_s3_bucket_ssm_tag_handler.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

  depends_on = [
    aws_s3_bucket.r_s3_bucket_ssm_tag_handler
  ]
}

#Create uploads folder
resource "aws_s3_object" "object" {
  bucket       = aws_s3_bucket.r_s3_bucket_ssm_tag_handler.id
  key          = "uploads/"
  content_type = "application/x-directory"
  kms_key_id   = var.v_tag_handler_kms_key
}
