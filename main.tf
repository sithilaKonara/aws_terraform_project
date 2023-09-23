
module "vpc" {
  source                               = "./modules/vpc"
  v_vpc_global_tags                    = var.v_global_tags
  v_vpc_cidr                           = var.v_vpc_cidr
  v_vpc_private_subnet                 = var.v_private_subnets
  v_vpc_public_subnet                  = var.v_public_subnets
  v_vpc_name                           = var.v_vpc_name
  v_vpc_availability_zones             = data.aws_availability_zones.available
  v_vpc_region                         = data.aws_region.current
  v_vpc_naas_spoke_key                 = var.v_naas_spoke_key
  v_vpc_naas_spoke_value               = var.v_naas_spoke_value
  v_vpc_amazon_side_asn                = var.v_amazon_side_asn
  v_vpc_logs_portal_public_subnets_vpn = var.v_public_subnets_vpn
}

module "system_manager" {
  source                                          = "./modules/system_manager"
  v_system_manager_aws_account                    = data.aws_caller_identity.current.account_id
  v_system_manager_aws_region                     = data.aws_region.current.name
  v_system_manager_cmk_aliases                    = var.v_cmk_aliases
  v_system_manager_iam_roles                      = var.v_iam_roles
  v_system_manager_iam_policies                   = var.v_iam_policies
  v_system_manager_patch_cycles                   = var.v_patch_cycles
  v_system_manager_lambda_functions               = var.v_lambda_functions
  v_system_manager_eb_rules                       = var.v_eb_rules
  v_system_manager_sns_notification               = var.v_sns_notification
  v_system_manager_ses_notification               = var.v_ses_notification
  v_system_manager_athena_workgroup               = var.v_athena_workgroup
  v_system_manager_bucket_name                    = var.v_bucket_name
  v_system_manager_glue_db                        = var.v_glue_db
  v_system_manager_patching_failure               = var.v_patching_failure_db
  v_system_manager_maintenance_windows            = var.v_patch_maintenance_windows
  v_system_manager_patch_deployment_tracker_table = var.v_patch_deployment_tracker_table
  v_system_manager_monthly_patching_data_table    = var.v_monthly_patching_data
}

module "patch_deployment_tracker" {
  source = "./modules/patch_deployment_tracker"

  v_aws_account                          = data.aws_caller_identity.current.account_id
  v_aws_region                           = data.aws_region.current.name
  v_pdt_name                             = module.system_manager.o_patch_deployment_tracker
  v_patch_cycles                         = var.v_patch_cycles
  v_pdt_embbeded_url_lamda_function_name = var.v_pdt_embbeded_url_lamda_function_name
  v_ptd_athena_workgroup                 = module.system_manager.o_ssm-athenaworkgroup
  v_pdt_athenaDynamoDB_connect_bkt       = var.v_pdt_athenaDynamoDB_connect_bkt

  depends_on = [
    module.system_manager
  ]
}

module "tags_reset" {
  source                    = "./modules/tags_reset"
  v_global_tags            = var.v_global_tags
  v_aws_account             = data.aws_caller_identity.current.account_id
  v_aws_region              = data.aws_region.current.name
  v_function_name           = var.v_tr_function_name
  v_ddb_name                = var.v_patch_deployment_tracker_table
  v_ecs_cluster_name        = var.v_tr_ecs_cluster_name
  v_s_private               = module.vpc.o_private_subnets
  v_kms_key_arn             = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
  v_sns_arn                 = module.system_manager.o_SSM-SNS_ARN
  v_automationExecutionRole = module.system_manager.o_ssm-automationExecutionRole
  v_tags_reset_pdt_table    = module.system_manager.o_patch_deployment_tracker

  depends_on = [
    module.vpc,
    module.system_manager,
    #module.patch_deployment_tracker
  ]
}

module "ssm_reporting" {
  source                        = "./modules/ssm_reporting"
  v_global_tags                = var.v_global_tags
  v_aws_account                 = data.aws_caller_identity.current.account_id
  v_aws_region                  = data.aws_region.current.name
  v_function_name               = var.v_reporting_function_name
  v_s_private                   = module.vpc.o_private_subnets
  v_kms_key_arn                 = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
  v_sns_arn                     = module.system_manager.o_SSM-SNS_ARN
  v_automationExecutionRole     = module.system_manager.o_ssm-automationExecutionRole
  v_ecsTaskExecutionRole        = module.tags_reset.o_iam_roles
  v_ecs_cluster_name            = module.tags_reset.o_ecs_cluster
  v_codebuildArtifactStore      = module.tags_reset.o_codepipeline_artifact_s3_bkt
  v_ssm_reporting_dynamodb_table = var.v_monthly_patching_data

  depends_on = [
    module.vpc,
    module.system_manager,
    module.tags_reset,
  ]
}

module "tag_handler" {
  source                                               = "./modules/tag_handler"
  v_tag_handler_aws_account                            = data.aws_caller_identity.current.account_id
  v_tag_handler_aws_region                             = data.aws_region.current.name
  v_tag_handler_function_name                          = var.v_th_function_name
  v_tag_handler_codepipeline_artifact_s3_bkt           = module.tags_reset.o_codepipeline_artifact_s3_bkt
  v_tag_handler_s3_bkt                                 = var.v_th_s3_bkt
  v_tag_handler_kms_key                                = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
  v_tag_handler_iam_roles                              = module.tags_reset.o_iam_roles
  v_tag_handler_iam_role_automation_execution          = module.system_manager.o_ssm-automationExecutionRole
  v_tag_handler_glue_ssm_global_resource_sync_database = module.system_manager.o_ssm_global_resource_sync_database
  v_tag_handler_s3_bucket_athena_query_result          = module.system_manager.o_s3_bucket_athena_query_result
  v_tag_handler_sns_ssm_arn                            = module.system_manager.o_SSM-SNS_ARN
  v_tag_handler_vpc_private_subnets                    = module.vpc.o_private_subnets
  v_tag_handler_ecs_cluster_name                       = module.tags_reset.o_ecs_cluster

  depends_on = [
    module.tags_reset,
    module.system_manager,
    module.vpc
  ]
}

module "email_handler" {
  source                                        = "./modules/email_handler"
  v_email_handler_aws_account                   = data.aws_caller_identity.current.account_id
  v_email_handler_aws_region                    = data.aws_region.current.name
  v_email_handler_function_name                 = var.v_eh_function_name
  v_email_handler_codepipeline_artifact_s3_bkt  = module.tags_reset.o_codepipeline_artifact_s3_bkt
  v_email_handler_eventbridge_rules             = var.v_eh_eventbridge_rules
  v_email_handler_iam_roles                     = module.tags_reset.o_iam_roles
  v_email_handler_iam_role_automation_execution = module.system_manager.o_ssm-automationExecutionRole
  v_email_handler_AdministrationRole            = module.system_manager.o_ssm-automationAdministrationRole
  v_email_handler_vpc_private_subnets           = module.vpc.o_private_subnets
  v_email_handler_ecs_cluster_name              = module.tags_reset.o_ecs_cluster
  v_email_handler_email_domain_arn              = module.system_manager.o_email_domain_arn
  v_email_handler_send_email_id_arn             = module.system_manager.o_email_sent_id_arn
  v_email_handler_kms_key_arn                   = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN

  depends_on = [
    module.tags_reset,
    module.system_manager,
    module.vpc
  ]
}

module "patch_completion" {
  source                                                = "./modules/patch_completion"
  v_patch_completion_global_tags                       = var.v_global_tags
  v_patch_completion_account_id                         = data.aws_caller_identity.current.account_id
  v_patch_completion_region                            = data.aws_region.current.name
  v_patch_completion_function_name                      = var.v_pc_function_name
  v_patch_completion_subnet_private                     = module.vpc.o_private_subnets
  v_patch_completion_ecsTaskExecutionRole               = module.tags_reset.o_iam_roles
  v_patch_completion_ecs_cluster_name                   = module.tags_reset.o_ecs_cluster
  v_patch_completion_codeBuildArtifactStore             = module.tags_reset.o_codepipeline_artifact_s3_bkt
  v_patch_completion_kms_key_arn                        = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
  v_patch_completion_ssm_global_resource_sync_database  = module.system_manager.o_ssm_global_resource_sync_database
  v_patch_completion_ssm_tag_instance_s3                = module.tag_handler.o_ssm_tag_instance_s3
  v_patch_completion_s3_bucket_athena_query_result      = module.system_manager.o_s3_bucket_athena_query_result
  v_patch_completion_resource_tags                      = var.v_pc_resource_tags
  v_patch_completion_iam_role_automation_execution      = module.system_manager.o_ssm-automationExecutionRole
  v_patch_completion_codebuildArtifactStore             = module.tags_reset.o_codepipeline_artifact_s3_bkt
  v_patch_completion_send_email_id_arn                  = module.system_manager.o_email_sent_id_arn
  v_patch_completion_email_domain_arn                   = module.system_manager.o_email_domain_arn
  v_patch_completion_pdt_table                          = module.system_manager.o_patch_deployment_tracker
  v_patch_completion_monthly_patching_failures_db_table = module.system_manager.o_ssm_monthly_patching_failures_database


  depends_on = [
    module.vpc,
    module.system_manager,
    module.tags_reset,
    module.tag_handler
  ]
}

# module "nfs_check" {
#   source                           = "./modules/nfs_check"
#   v_global_tags                   = var.v_global_tags
#   v_aws_account                    = data.aws_caller_identity.current.account_id
#   v_aws_region                     = data.aws_region.current.name
#   v_function_name                  = var.v_nfs_check_function_name
#   v_s_private                      = module.vpc.o_private_subnets
#   v_ecsTaskExecutionRole           = module.tags_reset.o_iam_roles
#   v_ecs_cluster_name               = module.tags_reset.o_ecs_cluster
#   v_codebuildArtifactStore         = module.tags_reset.o_codepipeline_artifact_s3_bkt
#   v_kms_key_arn                    = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
#   v_automationExecutionRole        = module.system_manager.o_ssm-automationExecutionRole
#   v_automationAdministrationRole   = module.system_manager.o_ssm-automationAdministrationRole
#   v_global_resource_sync_database  = module.system_manager.o_ssm_global_resource_sync_database
#   v_global_resource_sync_s3_bucket = module.system_manager.o_ssm_global_resource_sync_bucket

#   depends_on = [
#     module.vpc,
#     module.system_manager,
#     module.tags_reset,
#     module.patch_completion
#   ]
# }

module "logs_portal" {
  source = "./modules/logs_portal"

  v_logs_portal_global_tags                       = var.v_global_tags
  v_logs_portal_account_id                         = data.aws_caller_identity.current.account_id
  v_logs_portal_region                             = data.aws_region.current.name
  v_logs_portal_function_name                      = var.v_lp_function_name
  v_logs_portal_subnet_private                     = module.vpc.o_private_subnets
  v_logs_portal_subnet_public                      = module.vpc.o_public_subnets
  v_logs_portal_ecsTaskExecutionRole               = module.tags_reset.o_iam_roles
  v_logs_portal_ecs_cluster_name                   = module.tags_reset.o_ecs_cluster_name
  v_logs_portal_codeBuildArtifactStore             = module.tags_reset.o_codepipeline_artifact_s3_bkt
  v_logs_portal_kms_key_arn                        = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
  v_logs_portal_ssm_global_resource_sync_database  = module.system_manager.o_ssm_global_resource_sync_database
  v_logs_portal_iam_role_automation_execution      = module.system_manager.o_ssm-automationExecutionRole
  v_logs_portal_vpc_id                             = module.vpc.o_aws_vpc
  v_logs_portal_security_groups_id                 = module.vpc.o_ssm_security_groups
  v_logs_portal_maintenance_windows_db_table       = module.system_manager.o_ssm_patch_maintenance_windows_database
  v_logs_portal_monthly_patching_failures_db_table = module.system_manager.o_ssm_monthly_patching_failures_database
  v_logs_portal_api_gateway_vpc_endpoint_id        = module.vpc.o_aws_vpc_endpoint["api-gateway-endpoint"]
  v_logs_portal_get_activation_codes_function_name = var.v_get_activation_codes_function_name
  v_logs_portal_ssm_private_api_gateway_name       = var.v_ssm_private_api_gateway_name
  # v_logs_portal_aws_vpc_id                         = module.vpc.aws_vpc.id
  v_logs_portal_s3_bucket = module.tag_handler.o_ssm_tag_instance_s3
  # v_logs_portal_public_subnets_vpn                = var.v_public_subnets_vpn
  # v_logs_portal_ssm_tag_instance_s3               = module.tag_handler.o_ssm_tag_instance_s3
  # v_logs_portal_s3_bucket_athena_query_result     = module.system_manager.o_s3_bucket_athena_query_result
  # v_logs_portal_resource_tags                     = var.v_pc_resource_tags
  # v_logs_portal_codebuildArtifactStore            = module.tags_reset.o_codepipeline_artifact_s3_bkt
  #### > Check below variable < ####

  depends_on = [
    module.vpc,
    module.system_manager,
    module.tags_reset,
    module.tag_handler
  ]
}

module "patch_failure_report" {
  source                                                      = "./modules/patch_failure_report"
  v_patch_failure_report_account_id                           = data.aws_caller_identity.current.account_id
  v_patch_failure_report_region                               = data.aws_region.current.name
  v_patch_failure_report_function_name                        = var.v_pfr_function_name
  v_patch_failure_report_monthly_patching_data_dynamodb_table = var.v_monthly_patching_data
  v_patch_failure_report_iam_role_automation_execution        = module.system_manager.o_ssm-automationExecutionRole
  v_patch_failure_report_eventbridge                          = module.system_manager.o_eventbridge_patchschduler
  v_patch_failure_report_domain_ses_arn                       = module.system_manager.o_email_domain_arn
  v_patch_failure_report_email_ses_arn                        = module.system_manager.o_email_sent_id_arn

  depends_on = [
    module.vpc,
    module.system_manager,
    module.tags_reset,
  ]
}


module "mi_deregistration" {
  source                                            = "./modules/mi_deregistration"
  v_mi_deregistration_global_tags                  = var.v_global_tags
  v_mi_deregistration_account_id                    = data.aws_caller_identity.current.account_id
  v_mi_deregistration_region                        = data.aws_region.current.name
  v_mi_deregistration_function_name                 = var.v_mid_function_name
  v_mi_deregistration_s3_bucket                     = module.tag_handler.o_ssm_tag_instance_s3
  v_mi_deregistration_kms_key_arn                   = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
  v_mi_deregistration_s3_bucket_athena_query_result = module.system_manager.o_s3_bucket_athena_query_result
  v_mi_deregistration_ssm_sns_arn                   = module.system_manager.o_SSM-SNS_ARN
  v_mi_deregistration_iam_role_automation_execution = module.system_manager.o_ssm-automationExecutionRole
  v_mi_deregistration_global_resource_sync_database = module.system_manager.o_ssm_global_resource_sync_database
  v_mi_deregistration_tag_handler_ecs_lambda        = module.tag_handler.o_ssm_tag_handler_ecs_lambda


  depends_on = [
    module.system_manager,
    module.tag_handler
  ]
}

module "s3_cleanup" {
  source                                      = "./modules/s3_cleanup"
  v_s3_cleanup_global_tags                   = var.v_global_tags
  v_s3_cleanup_account_id                     = data.aws_caller_identity.current.account_id
  v_s3_cleanup_region                         = data.aws_region.current.name
  v_s3_cleanup_function_name                  = var.v_s3c_function_name
  v_s3_cleanup_s3_bucket                      = module.tag_handler.o_ssm_tag_instance_s3
  v_s3_cleanup_kms_key_arn                    = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
  v_s3_cleanup_s3_bucket_athena_query_result  = module.system_manager.o_s3_bucket_athena_query_result
  v_s3_cleanup_ssm_sns_arn                    = module.system_manager.o_SSM-SNS_ARN
  v_s3_cleanup_iam_role_automation_execution  = module.system_manager.o_ssm-automationExecutionRole
  v_s3_cleanup_global_resource_sync_database  = module.system_manager.o_ssm_global_resource_sync_database
  v_s3_cleanup_global_resource_sync_s3_bucket = module.system_manager.o_ssm_global_resource_sync_bucket

  depends_on = [
    module.system_manager,
    module.tag_handler
  ]
}

module "hybrid_activation" {
  source                                                 = "./modules/hybrid_activation"
  v_hybrid_activation_global_tags                       = var.v_global_tags
  v_hybrid_activation_account_id                         = data.aws_caller_identity.current.account_id
  v_hybrid_activation_region                             = data.aws_region.current.name
  v_hybrid_activation_function_name                      = var.v_ha_function_name
  v_hybrid_activation_s3_bucket                          = module.tag_handler.o_ssm_tag_instance_s3
  v_hybrid_activation_kms_key_arn                        = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN
  v_hybrid_activation_ssm_sns_arn                        = module.system_manager.o_SSM-SNS_ARN
  v_hybrid_activation_iam_role_automation_execution      = module.system_manager.o_ssm-automationExecutionRole
  v_hybrid_activation_automation_administration_iam_role = module.system_manager.o_ssm-automationAdministrationRole
  v_hybrid_activation_member_accounts                    = var.v_member_accounts

  depends_on = [
    module.system_manager,
    module.tag_handler
  ]
}

module "ms_teams_notifications" {
  source                                 = "./modules/ms_teams_notifications"
  v_ms_teams_notifications_global_tags  = var.v_global_tags
  v_ms_teams_notifications_account_id    = data.aws_caller_identity.current.account_id
  v_ms_teams_notifications_region        = data.aws_region.current.name
  v_ms_teams_notifications_function_name = var.v_mstn_function_name
  v_ms_teams_notifications_s3_bucket     = module.tag_handler.o_ssm_tag_instance_s3
  v_ms_teams_notifications_kms_key_arn   = module.system_manager.o_SSM-ManagedInstanceDataEncryptionKey_ARN

  depends_on = [
    module.system_manager,
    module.tag_handler
  ]
}

# module "biscom_notification" {
#   source                                   = "./modules/biscom_notification"
#   v_biscom_notification_account_id         = data.aws_caller_identity.current.account_id
#   v_biscom_notification_region             = data.aws_region.current.name
#   v_biscom_notification_function_name      = var.v_biscom_function_name
#   v_biscom_notification_ssm_ses_email_arn  = module.system_manager.o_email_sent_id_arn
#   v_biscom_notification_ssm_ses_domain_arn = module.system_manager.o_email_domain_arn
#   v_biscom_notification_recievers          = var.v_biscom_notification_recievers
#   v_biscom_notification_ses_sender         = var.v_ses_notification["ses_email_identity"]
# }

module "connection_lost_servers" {
  source                                                 = "./modules/connection_lost_servers"
  v_connection_lost_servers_aws_account                  = data.aws_caller_identity.current.account_id
  v_connection_lost_servers_aws_region                   = data.aws_region.current.name
  v_connection_lost_servers_function_name                = var.v_cls_function_name
  v_connection_lost_servers_codepipeline_artifact_s3_bkt = module.tags_reset.o_codepipeline_artifact_s3_bkt
  v_connection_lost_servers_member_accounts              = var.v_member_accounts
  # v_connection_lost_servers_eventbridge_rules             = var.v_eh_eventbridge_rules
  # v_connection_lost_servers_iam_roles                     = module.tags_reset.o_iam_roles
  v_connection_lost_servers_iam_role_automation_execution = module.system_manager.o_ssm-automationExecutionRole
  # v_connection_lost_servers_vpc_private_subnets           = module.vpc.o_private_subnets
  # v_connection_lost_servers_ecs_cluster_name              = module.tags_reset.o_ecs_cluster
  v_connection_lost_servers_lambda_ecs_iam_roles = module.tags_reset.o_iam_roles

  depends_on = [
    module.tags_reset,
    module.system_manager,
    module.vpc
  ]
}
