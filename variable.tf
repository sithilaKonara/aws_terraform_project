### global Global tags ###
variable "v_global_tags" {
  type = map(any)
}

#### Network variables #####

variable "v_vpc_cidr" {
  type = string
}

variable "v_private_subnets" {
  type = list(any)
}

variable "v_public_subnets" {
  type = list(any)
}

variable "v_vpc_name" {
  type = string
}
variable "v_naas_spoke_key" {

}
variable "v_naas_spoke_value" {}
variable "v_amazon_side_asn" {

}
#### system manager variables ####

variable "v_cmk_aliases" {
  type = string
}
variable "v_iam_roles" {
  type = map(any)
}
variable "v_iam_policies" {
  type = map(any)
}
variable "v_patch_cycles" {
  type = list(any)
}
variable "v_lambda_functions" {
  type = map(any)
}
variable "v_eb_rules" {
  type = map(any)
}
variable "v_sns_notification" {
  type = map(any)
}
variable "v_ses_notification" {
  type = map(any)
}
variable "v_bucket_name" {
  type = map(any)
}
variable "v_athena_workgroup" {
  type = map(any)
}

variable "v_glue_db" {
  type = string
}

variable "v_patching_failure_db" {
  type = string
}

variable "v_patch_maintenance_windows" {
  type = string
}

#### Module - tag_reset #####
variable "v_tr_function_name" {}
variable "v_tr_ecs_cluster_name" {
  type = string
}

#### Module - SSM reporting ####
variable "v_reporting_function_name" {}

#### Module - Patch deployment tracker ####
variable "v_patch_deployment_tracker_table" {}
variable "v_pdt_embbeded_url_lamda_function_name" {}
variable "v_pdt_athenaDynamoDB_connect_bkt" {}

# NFS check function name
variable "v_nfs_check_function_name" {}

###Module tag handler###
variable "v_th_function_name" {}
variable "v_th_s3_bkt" {}

###Email handler###
variable "v_eh_function_name" {}
variable "v_eh_eventbridge_rules" {}

# Patch Completion 
variable "v_pc_function_name" {}
variable "v_pc_resource_tags" {
  type = map(any)
}

# Logs Portal
variable "v_lp_function_name" {}
variable "v_public_subnets_vpn" {}

###Patch failure report###
variable "v_pfr_function_name" {}
variable "v_monthly_patching_data" {}

variable "v_mid_function_name" {}

variable "v_s3c_function_name" {}

variable "v_ha_function_name" {}

variable "v_member_accounts" {

}

variable "v_mstn_function_name" {

}

variable "v_cls_function_name" {

}

variable "v_get_activation_codes_function_name" {}

variable "v_ssm_private_api_gateway_name" {}

variable "v_biscom_function_name" {}

variable "v_biscom_notification_recievers" {}

