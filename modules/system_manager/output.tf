#Return DKIM tokens
output "o_ses_domain_DKIM_CNAMES" {
  value = formatlist("%s._domainkey.%s   -   %s.dkim.amazonses.com", aws_ses_domain_dkim.r_ses_domain_dkim.dkim_tokens, aws_ses_domain_identity.r_ses_domain_id.domain, aws_ses_domain_dkim.r_ses_domain_dkim.dkim_tokens)
}

output "o_SSM-ManagedInstanceDataEncryptionKey_ARN" {
  value = aws_kms_key.r_cmk.arn
}

output "o_SSM-SNS_ARN" {
  value = aws_sns_topic.r_ssm_cps.arn
}

output "o_ssm-automationExecutionRole" {
  value = {
    "ssm-automationExecutionRole_name" = aws_iam_role.r_role_ssm_AutomationExecutionRole.name,
    "ssm-automationExecutionRole_arn"  = aws_iam_role.r_role_ssm_AutomationExecutionRole.arn
  }
}

output "o_ssm-automationAdministrationRole" {
  value = {
    "ssm-automationAdministrationRole_name" = aws_iam_role.r_role_ssm_AutomationAdministrationRole.name,
    "ssm-automationAdministrationRole_arn"  = aws_iam_role.r_role_ssm_AutomationAdministrationRole.arn
  }
}

output "o_ssm-athenaworkgroup" {
  value = aws_athena_workgroup.r_athena_workgroup.arn
}

output "o_ssm_global_resource_sync_database" {
  value = aws_glue_catalog_database.r_aws_glue_catalog_database.name
}

output "o_ssm_patch_maintenance_windows_database" {
  value = aws_dynamodb_table.r_ssm_patch-maintenance-windows
}

output "o_ssm_monthly_patching_failures_database" {
  value = aws_dynamodb_table.r_ssm_patching_failures
}
output "o_ssm_global_resource_sync_bucket" {
  value = aws_s3_bucket.r_resource_data_sync.id
}

output "o_s3_bucket_athena_query_result" {
  value = aws_s3_bucket.r_athena_query_result.id
}

output "o_eventbridge_patchschduler" {
  value = aws_cloudwatch_event_rule.r_eb_patchschduler
}

output "o_email_sent_id_arn" {
  value = aws_ses_email_identity.r_ses_email_id.arn
}

output "o_email_domain_arn" {
  value = aws_ses_domain_identity.r_ses_domain_id.arn
}

output "o_patch_deployment_tracker" {
  value = aws_dynamodb_table.r_ssm_patch_deployment_tracker
}
