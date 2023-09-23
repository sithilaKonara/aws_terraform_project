#Create uploads folder
resource "aws_s3_object" "object" {
  bucket       = var.v_patch_completion_ssm_tag_instance_s3.id
  key          = "documents/"
  content_type = "application/x-directory"
  kms_key_id   = var.v_patch_completion_kms_key_arn
}
