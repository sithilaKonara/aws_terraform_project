#Create dynamodb table
# resource "aws_dynamodb_table" "r_pdt_table" {
#   name           = var.v_pdt_name
#   billing_mode   = "PROVISIONED"
#   read_capacity  = 1
#   write_capacity = 1
#   hash_key       = "Patch Cycle"

#   attribute {
#     name = "Patch Cycle"
#     type = "S"
#   }
#   point_in_time_recovery {
#     enabled = true
#   }
# }

# Configure dynamodb autoscaling settings - read(units) capacity
# resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
#   max_capacity       = 10
#   min_capacity       = 1
#   resource_id        = "table/${var.v_pdt_name.name}"
#   scalable_dimension = "dynamodb:table:ReadCapacityUnits"
#   service_namespace  = "dynamodb"
# }
# # Configure dynamodb autoscaling settings - write(units) capacity
# resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
#   max_capacity       = 10
#   min_capacity       = 1
#   resource_id        = "table/${var.v_pdt_name.name}"
#   scalable_dimension = "dynamodb:table:WriteCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# # Configure dynamodb autoscaling settings - read(%) capacity
# resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
#   name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.dynamodb_table_read_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBReadCapacityUtilization"
#     }

#     target_value = 70
#   }
# }

# # Configure dynamodb autoscaling settings - write(%) capacity
# resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
#   name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target.resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.dynamodb_table_write_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBWriteCapacityUtilization"
#     }

#     target_value = 70
#   }
# }

# Add data
resource "aws_dynamodb_table_item" "r_pdt_table_data" {
  count      = length(var.v_patch_cycles)
  table_name = var.v_pdt_name.name
  hash_key   = var.v_pdt_name.hash_key

  item = <<ITEM
{
  "Patch Cycle": {"S": "${var.v_patch_cycles[count.index]}"},
  "Patch Status": {"S": "Pending"}
}
ITEM
}
