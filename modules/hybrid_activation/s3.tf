resource "aws_s3_object" "object" {
  bucket       = var.v_hybrid_activation_s3_bucket.id
  key          = "activations/"
  content_type = "application/x-directory"
  kms_key_id   = var.v_hybrid_activation_kms_key_arn
}
