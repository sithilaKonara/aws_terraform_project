# resource "aws_dynamodb_table" "r_ssm_reporting_dynamodb" {
#   name           = "monthly-patching-data"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "InstanceId"
#   range_key      = "Timestamp"
#   table_class    = "STANDARD"
#   stream_enabled = false
#   point_in_time_recovery {
#     enabled = true
#   }

#   attribute {
#     name = "InstanceId"
#     type = "S"
#   }

#   attribute {
#     name = "Timestamp"
#     type = "N"
#   }

#   ttl {
#     attribute_name = "TimeToExist"
#     enabled        = false
#   }
# }