# output "o_ssm_tag_instance_s3" {
#     value = aws_s3_bucket.r_s3_bucket_ssm_tag_handler.bucket
# }

output "o_ssm_tag_instance_s3" {
  value = aws_s3_bucket.r_s3_bucket_ssm_tag_handler
}

output "o_ssm_tag_handler_ecs_lambda" {
  value = aws_lambda_function.r_lambda_function_ssm_tag_handler_ecs
}
