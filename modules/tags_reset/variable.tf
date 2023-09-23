### abccompany Global tags ###
variable "v_global_tags" {
  type = map(any)
}

# ### Platform-OS team tags ###
# variable "v_poos_tags" {
#   type = map(any)
# }

###
variable "v_aws_account" {
  type = string
}

variable "v_aws_region" {
  type = string
}

variable "v_function_name" {}

variable "v_s_private" {
  type = map(any)
}

variable "v_ddb_name" {
  type = string
}

variable "v_ecs_cluster_name" {
  type = string
}

variable "v_kms_key_arn" {
  type = string
}

variable "v_sns_arn" {
  type = string
}

variable "v_automationExecutionRole" {}

variable "v_tags_reset_pdt_table" {
}
