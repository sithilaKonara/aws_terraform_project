
#Create uploads folder
resource "aws_s3_object" "object" {
  bucket       = var.v_mi_deregistration_s3_bucket.id
  key          = "decom/"
  content_type = "application/x-directory"
  kms_key_id   = var.v_mi_deregistration_kms_key_arn
}


#Enable ssm tag instance bucket event notification
resource "aws_s3_bucket_notification" "r_s3_bucket_notification_ssm_mi_deregistration" {
  bucket = var.v_mi_deregistration_s3_bucket.id

  lambda_function {
    id                  = "mi-decom notification"
    lambda_function_arn = aws_lambda_function.r_lambda_function_ssm_mi_deregistration.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "decom"
  }

  lambda_function {
    id                  = "tag-handler_ecs notification"
    lambda_function_arn = var.v_mi_deregistration_tag_handler_ecs_lambda.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "uploads"
  }

  depends_on = [
    aws_lambda_function.r_lambda_function_ssm_mi_deregistration
  ]
}
