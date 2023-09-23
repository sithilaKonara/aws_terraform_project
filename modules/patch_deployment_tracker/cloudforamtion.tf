# resource "aws_cloudformation_stack" "r_athena_dynamodb_connector_cf_stack" {
#   name = "ssm-serverlessrepo-AthenaDynamoDBConnector"
#   tags = {
#     "serverlessrepo:applicationId"   = "arn:aws:serverlessrepo:us-east-1:292517598671:applications/AthenaDynamoDBConnector"
#     "serverlessrepo:semanticVersion" = "2022.24.1"
#   }

#   parameters = {
#     AthenaCatalogName      = "dynamodbdata"
#     DisableSpillEncryption = false
#     LambdaMemory           = 3008
#     LambdaTimeout          = 900
#     SpillBucket            = aws_s3_bucket.r_ddb_connector_bkt.id
#     SpillPrefix            = "athena-spill"
#   }

#   capabilities  = ["CAPABILITY_IAM"]
#   template_body = <<DOC
#     ${file("patch_deployment_tracker\\Documents\\athenadynamodbconnector_template.json")}
#     DOC
# }
