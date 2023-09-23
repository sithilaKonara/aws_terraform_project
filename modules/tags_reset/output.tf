output "o_ecs_cluster" {
  value = aws_ecs_cluster.r_ssm_ecsCluster_name.arn
}


# ECS cluster output need to be review and get common output for other functions.
output "o_ecs_cluster_name" {
  value = aws_ecs_cluster.r_ssm_ecsCluster_name.name
}

# output "o_codepipeline_artifact_s3_bkt" {
#   value = {
#     s3_store_artifacts_id = "${aws_s3_bucket.r_s3_ssm-codepipelineArtifact_store.id}",
#     s3_store_artifacts_arn = "${aws_s3_bucket.r_s3_ssm-codepipelineArtifact_store.arn}"
#   }
# }

output "o_codepipeline_artifact_s3_bkt" {
  value = aws_s3_bucket.r_s3_ssm-codepipelineArtifact_store
}

output "o_iam_roles" {
  value = {

    ecsTasExecutionRole = "${aws_iam_role.r_ssm_ecsTasExecutionRole.arn}",
    lambdaECS           = "${aws_iam_role.r_ssm_lambdaECS.arn}",
    ecsTaskRole         = "${aws_iam_role.r_ssm_tagsReset_ecsTaskRole.arn}"
  }
}

output "o_python_base_image_ecr_uri" {
  value = aws_ecr_repository.r_ecr_python_image.repository_url
}
