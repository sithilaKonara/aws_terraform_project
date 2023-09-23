# # #Return DKIM tokens
# output "o_ses_domain_DKIM_CNAMES" {
#   value = module.system_manager.o_ses_domain_DKIM_CNAMES
# }

# output "o_resource_data_sync_parameters" {
#   value = {
#     "Bucket name"   = module.system_manager.o_ssm_global_resource_sync_bucket,
#     "Bucket region" = data.aws_region.current.id,
#     "KMS Key ARN"   = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN,
#   }
# }

# output "o_Deployment_Group_Name" {
#   value = module.logs_portal.Deployment_group_name
# }

# output "o_python_base_image-uri" {
#   value = module.tags_reset.o_python_base_image_ecr_uri
# }

# output "o_php-apache_base_image-uri" {
#   value = module.logs_portal.o_php_apache_base_image_ecr_uri
# }
