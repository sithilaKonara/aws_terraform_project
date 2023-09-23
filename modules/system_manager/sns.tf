# Create SNS topic
resource "aws_sns_topic" "r_ssm_cps" {
  name              = var.v_system_manager_sns_notification["sns_name"]
  display_name      = "Patching Notifications"
  delivery_policy   = <<EOF
  {
    "http": {
      "defaultHealthyRetryPolicy": {
        "minDelayTarget": 20,
        "maxDelayTarget": 20,
        "numRetries": 3,
        "numMaxDelayRetries": 0,
        "numNoDelayRetries": 0,
        "numMinDelayRetries": 0,
        "backoffFunction": "linear"
      },
    "disableSubscriptionOverrides": false
    }
  }
  EOF
  kms_master_key_id = aws_kms_alias.r_cmk_aliases.name
}

# Create SNS topic policy
resource "aws_sns_topic_policy" "r_default" {
  arn    = aws_sns_topic.r_ssm_cps.arn
  policy = data.aws_iam_policy_document.d_ssm_cps.json
}

# Create SNS subscription
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.r_ssm_cps.arn
  protocol  = "email"
  endpoint  = var.v_system_manager_sns_notification["sns_subscription"]
}
