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
variable "v_s_private" {
  type = map(any)
}
variable "v_ecs_cluster_name" {
  type = string
}

variable "v_function_name" {
  type = string

}

variable "v_kms_key_arn" {
  type = string
}

variable "v_sns_arn" {
  type = string
}

variable "v_automationExecutionRole" {}

variable "v_ecsTaskExecutionRole" {}

variable "v_codebuildArtifactStore" {}

variable "v_ssm_reporting_dynamodb_table" {}
