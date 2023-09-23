# Create email identity resource
resource "aws_ses_email_identity" "r_ses_email_id" {
  email = var.v_system_manager_ses_notification["ses_email_identity"]
}
#Create doamin identity resource
#### >> DO NOT change anything in DOMAIN section!! << ####
### > We have to request DNS team to re-create CNAMES if we change this < ###
resource "aws_ses_domain_identity" "r_ses_domain_id" {
  domain = var.v_system_manager_ses_notification["ses_domain_identity"]
}
#Provides an SES domain DKIM generation resource.
resource "aws_ses_domain_dkim" "r_ses_domain_dkim" {
  domain = aws_ses_domain_identity.r_ses_domain_id.domain
}

####May not required#####

# # Create SES configuration set
# resource "aws_ses_configuration_set" "r_ses_configurationSet" {
#   name                       = var.v_system_manager_ses_notification["ses_configuration_set"]
#   reputation_metrics_enabled = true
# }

# # Create SES configuration set event destination
# resource "aws_ses_event_destination" "r_ses_configurationSet_eventDestination" {
#   name                   = "${var.v_system_manager_ses_notification["ses_configuration_set"]}-event_destinations"
#   configuration_set_name = aws_ses_configuration_set.r_ses_configurationSet.name
#   enabled                = true
#   matching_types = [
#     "bounce",
#     "send",
#     "reject",
#     "complaint",
#     "delivery",
#     "open",
#     "click",
#     "renderingFailure"
#   ]
#   sns_destination {
#     topic_arn = aws_sns_topic.r_ssm_cps.arn
#   }
# }
