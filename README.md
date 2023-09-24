# aws_terraform_project

This project contains the Terraform code for deploying resources for an Onprem server patching automation on AWS.

## File Structure

```bash


│   .gitignore
│   README.md
│   data.tf
│   main.tf
│   output.tf
│   variable.tf
│
├───modules
│   └───connection_lost_servers
│   └───email_handler
│   └───hybrid_activation
│   └───logs_portal
│   └───mi_deregistration
│   └───ms_teams_notifications
│   └───patch_completion
│   └───patch_deployment_tracker
│   └───patch_failure_report
│   └───s3_cleanup
│   └───ssm_reporting
│   └───system_manager
│   └───tag_handler
│   └───tags_reset
│   └───vpc

