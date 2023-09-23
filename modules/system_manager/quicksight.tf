# resource "aws_quicksight_data_source" "r_montly_patching_report_dataset" {
#   data_source_id = "montly_patching_report"
#   name           = "montly_patching_report"
#   parameters {
#     athena {
#       work_group = aws_athena_workgroup.r_athena_workgroup.name
#     }
#   }
#   type = "ATHENA"
# }
