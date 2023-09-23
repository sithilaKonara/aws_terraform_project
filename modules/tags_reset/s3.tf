#Create Codepipeline Artifact bucket
resource "aws_s3_bucket" "r_s3_ssm-codepipelineArtifact_store" {
  bucket = "ssm-codepipeline-artifact-store-${var.v_aws_region}-${var.v_aws_account}"
  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"
  #     }
  #   }
  # }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "r_s3_ssm-codepipelineArtifact_store_serverside_encryption" {
  bucket = aws_s3_bucket.r_s3_ssm-codepipelineArtifact_store.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "r_s3_codepipelineArtifact_store_bucketPolicy" {
  bucket = aws_s3_bucket.r_s3_ssm-codepipelineArtifact_store.id
  policy = data.aws_iam_policy_document.d_pd_codepipelineArtifact_store_bucketPolicy.json
}








