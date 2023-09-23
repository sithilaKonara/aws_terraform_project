resource "aws_glue_catalog_database" "r_aws_glue_catalog_database" {
  name        = var.v_system_manager_glue_db
  description = "SSM automation global resource data sync"
}

resource "aws_glue_crawler" "r_ssmGlueCrawler" {
  database_name = aws_glue_catalog_database.r_aws_glue_catalog_database.name
  name          = "SSM-GlueCrawler"
  role          = aws_iam_role.r_AWSGlueServiceRole.arn
  schedule      = "cron(00 00 * * ? *)"

  s3_target {
    path       = "s3://${aws_s3_bucket.r_resource_data_sync.bucket}"
    exclusions = ["AWS:InstanceInformation/accountid=*/test.json"]
  }
  depends_on = [
    aws_s3_bucket.r_resource_data_sync,
    aws_iam_role.r_AWSGlueServiceRole
  ]
}
