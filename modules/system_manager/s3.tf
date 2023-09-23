
# Create SSM resouce sync bucket
resource "aws_s3_bucket" "r_resource_data_sync" {
  bucket = "${var.v_system_manager_bucket_name["resource_data_sync"]}-${var.v_system_manager_aws_region}-${var.v_system_manager_aws_account}"
}
# Block SSM resouce sync bucket public access
resource "aws_s3_bucket_public_access_block" "r_aws_s3_bucket_public_access_block_resource_data_sync" {
  bucket = aws_s3_bucket.r_resource_data_sync.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# SSM resource sync bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {

  bucket = aws_s3_bucket.r_resource_data_sync.id
  policy = jsonencode({
    Version : "2008-10-17",
    Statement : [
      {
        Sid : "SSMBucketPermissionsCheck",
        Effect : "Allow",
        Principal : {
          Service : "ssm.amazonaws.com"
        },
        Action : "s3:GetBucketAcl",
        Resource : "${aws_s3_bucket.r_resource_data_sync.arn}"
      },
      {
        Sid : "SSMBucketDelivery",
        Effect : "Allow",
        Principal : {
          Service : "ssm.amazonaws.com"
        },
        Action : "s3:PutObject",
        Resource : "${aws_s3_bucket.r_resource_data_sync.arn}/*",
        Condition : {
          StringEquals : {
            "s3:x-amz-server-side-encryption-aws-kms-key-id" : "${aws_kms_key.r_cmk.arn}",
            "s3:x-amz-server-side-encryption" : "aws:kms"
          }
        }
      },
      {
        Sid : "SSMWrite",
        Effect : "Allow",
        Principal : "*",
        Action : "s3:PutObject",
        Resource : "${aws_s3_bucket.r_resource_data_sync.arn}/*",
        Condition : {
          StringEquals : {
            "aws:PrincipalOrgID" : "o-njq6j1wsrz",
          }
        }
      },
      {
        Sid : "SSMBucketDeliveryTagging",
        Effect : "Allow",
        Principal : {
          Service : "ssm.amazonaws.com"
        },
        Action : "s3:PutObjectTagging",
        Resource : "${aws_s3_bucket.r_resource_data_sync.arn}/*"
      }
    ]
    }

  )
}
# SSM resource sync bucket life cycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "r_resource_data_sync_life_cycle" {
  bucket = aws_s3_bucket.r_resource_data_sync.id

  rule {
    id = "delete_old_versions"
    noncurrent_version_expiration {
      noncurrent_days = 10
    }
    status = "Enabled"
  }
}
# SSM resource sync bucket enable versioning
resource "aws_s3_bucket_versioning" "r_resource_data_sync_versioning" {
  bucket = aws_s3_bucket.r_resource_data_sync.id
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [
    aws_s3_bucket.r_resource_data_sync
  ]
}
# SSM resource sync bucket data encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "r_aws_s3_bucket_server_side_encryption_configuration_resource_data_sync" {
  bucket = aws_s3_bucket.r_resource_data_sync.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.r_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
# Create athena query result bucket
resource "aws_s3_bucket" "r_athena_query_result" {
  bucket = "${var.v_system_manager_bucket_name["athena-query-result"]}-${var.v_system_manager_aws_region}-${var.v_system_manager_aws_account}"
}
# Block SSM athena query results bucket public access
resource "aws_s3_bucket_public_access_block" "r_block_access_02" {
  bucket                  = aws_s3_bucket.r_athena_query_result.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
# SSM athena query results bucket data encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "r_aws_s3_bucket_server_side_encryption_configuration_athena_query_result" {
  bucket = aws_s3_bucket.r_athena_query_result.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.r_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
