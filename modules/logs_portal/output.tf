output "Deployment_group_name" {
  value = aws_codedeploy_deployment_group.r_codedeploy_group_logs_portal.id
}

output "o_php_apache_base_image_ecr_uri" {
  value = aws_ecr_repository.r_ecr_php_apache_image.repository_url
}
