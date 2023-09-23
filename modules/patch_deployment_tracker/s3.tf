resource "aws_s3_bucket" "r_ddb_connector_bkt" {
  bucket = "${var.v_pdt_athenaDynamoDB_connect_bkt}-${var.v_aws_region}-${var.v_aws_account}"
}

resource "aws_s3_bucket_versioning" "r_ddb_connector_bkt_version" {
  bucket = aws_s3_bucket.r_ddb_connector_bkt.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "r_ddb_connector_bkt_encryption" {
  bucket = aws_s3_bucket.r_ddb_connector_bkt.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "r_ddb_connector_bkt_block_public_access" {
  bucket                  = aws_s3_bucket.r_ddb_connector_bkt.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
