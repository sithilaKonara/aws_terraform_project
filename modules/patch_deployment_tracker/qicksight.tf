# resource "aws_quicksight_data_source" "r_qsds_pdt" {
#   data_source_id = "ssm-patch-deployment-tracker"
#   name           = "ssm-patch-deployment-tracker"

#   parameters {
#     athena {
#       work_group = var.v_ptd_athena_workgroup
#     }
#   }

#   type = "ATHENA"
# }
