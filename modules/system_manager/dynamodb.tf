# Creating "monthly-patching-failures" DynamoDB table
resource "aws_dynamodb_table" "r_ssm_patching_failures" {
  name         = var.v_system_manager_patching_failure
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "InstanceId"
  range_key    = "month-year"
  table_class  = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = "InstanceId"
    type = "S"
  }

  attribute {
    name = "month-year"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}
# Create "patch-maintenance-windows" DynamoDB table
resource "aws_dynamodb_table" "r_ssm_patch-maintenance-windows" {
  name         = var.v_system_manager_maintenance_windows
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "month-year"
  range_key    = "patching_cycle"
  table_class  = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = "month-year"
    type = "S"
  }

  attribute {
    name = "patching_cycle"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}
# Create "patch-deployment-tracker" DynamoDB table
resource "aws_dynamodb_table" "r_ssm_patch_deployment_tracker" {
  name         = var.v_system_manager_patch_deployment_tracker_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Patch Cycle"
  table_class  = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = "Patch Cycle"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}
# Create "monthly patching data" DynamoDB table
resource "aws_dynamodb_table" "r_ssm_monthly_patching_data" {
  name         = var.v_system_manager_monthly_patching_data_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "InstanceId"
  range_key    = "Timestamp"
  table_class  = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = "InstanceId"
    type = "S"
  }
  attribute {
    name = "Timestamp"
    type = "N"
  }
  point_in_time_recovery {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}




# Configure dynamodb autoscaling settings - read(units) capacity
# resource "aws_appautoscaling_target" "r_patch_maintenance_window_read_target" {
#   max_capacity       = 10
#   min_capacity       = 1
#   resource_id        = "table/${aws_dynamodb_table.r_ssm_patch-maintenance-windows.name}"
#   scalable_dimension = "dynamodb:table:ReadCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# Configure dynamodb autoscaling settings - write(units) capacity
# resource "aws_appautoscaling_target" "r_patch_maintenance_window_write_target" {
#   max_capacity       = 10
#   min_capacity       = 1
#   resource_id        = "table/${aws_dynamodb_table.r_ssm_patch-maintenance-windows.name}"
#   scalable_dimension = "dynamodb:table:WriteCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# Configure dynamodb autoscaling settings - read(%) capacity
# resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
#   name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.r_patch_maintenance_window_read_target.resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.r_patch_maintenance_window_read_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.r_patch_maintenance_window_read_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.r_patch_maintenance_window_read_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBReadCapacityUtilization"
#     }

#     target_value = 70
#   }
# }

# Configure dynamodb autoscaling settings - write(%) capacity
# resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
#   name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.r_patch_maintenance_window_write_target.resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.r_patch_maintenance_window_write_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.r_patch_maintenance_window_write_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.r_patch_maintenance_window_write_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBWriteCapacityUtilization"
#     }

#     target_value = 70
#   }
# }
