# Create inline policy for SSM automation administration role
data "aws_iam_policy_document" "d_ssm_AutomationAdministrationRole" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    # resources = ["arn:aws:iam::*:role/AWS-SystemsManager-AutomationExecutionRole"]
    resources = ["arn:aws:iam::*:role/${var.v_system_manager_iam_roles["ssm-AutomationExecutionRole"]}"]
  }
  statement {
    effect    = "Allow"
    actions   = ["organizations:ListAccountsForParent"]
    resources = ["*"]
  }
}
# Create inline policy for SSM automation executionRole role
data "aws_iam_policy_document" "d_ssm_AutomationExecutionRole" {
  statement {
    effect = "Allow"
    actions = [
      "resource-groups:ListGroupResources",
      "tag:GetResources",
      "lambda:InvokeFunction"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]
    #### >> Added the account ID to the role name << ####
    # resources = ["arn:aws:iam::${var.v_system_manager_aws_account}:role/${var.v_system_manager_iam_roles["ssm-AutomationExecutionRole"]}-${var.v_system_manager_aws_account}"] #### > Existing value < ####
    resources = ["arn:aws:iam::${var.v_system_manager_aws_account}:role/${var.v_system_manager_iam_roles["ssm-AutomationExecutionRole"]}"]
  }
}
# Create inline policy for SSM automation handler IAM role 
data "aws_iam_policy_document" "d_ssm_AutomationHandler" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [aws_kms_key.r_cmk.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.r_ssm_cps.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [aws_iam_role.r_role_ssm_AutomationAdministrationRole.arn]
  }
}
# Create policy document for SNS topic policy
data "aws_iam_policy_document" "d_ssm_cps" {
  version   = "2008-10-17"
  policy_id = "__default_policy_ID"
  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [aws_sns_topic.r_ssm_cps.arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = ["${var.v_system_manager_aws_account}"]
    }
  }
}

# Create SSM automation data encryption key policy
data "aws_iam_policy_document" "d_cmk_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.v_system_manager_aws_account}:root",
        #aws_iam_user.r_t10_unmapping.arn,
        #aws_iam_user.r_ssm_orchestrator_user.arn       
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.r_role_QuicksightS3ConsumersRole.arn]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*"
    ]
    resources = ["*"]

  }
  statement {
    sid    = "Allow Permission to AWSSSMServiceRoles"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::899879149844:role/AWSSSMServiceRole",
        "arn:aws:iam::383586206651:role/AWSSSMServiceRole"
      ]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow use of the key by Systems Manager"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow use of the key by service roles within the organization"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = ["o-njq6j1wsrz"]
    }
  }
}
# Create AWSQuickSightS3ConsumersPolicy policy
data "aws_iam_policy_document" "d_AWSQuickSightS3ConsumersPolicy" {
  #Partially coded
  statement {
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.r_resource_data_sync.arn,
      aws_s3_bucket.r_athena_query_result.arn,
      #"arn:aws:s3:::ssm-tag-instance-ap-southeast-1-793820306412",
      #"arn:aws:s3:::athena-dynamodb-connector-spill-bucket"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "${aws_s3_bucket.r_resource_data_sync.arn}/*",
      "${aws_s3_bucket.r_athena_query_result.arn}/*",
      #"arn:aws:s3:::ssm-tag-instance-ap-southeast-1-793820306412/*",
      #"arn:aws:s3:::athena-dynamodb-connector-spill-bucket/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.r_resource_data_sync.arn,
      aws_s3_bucket.r_athena_query_result.arn,
      #"arn:aws:s3:::athena-dynamodb-connector-spill-bucket"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      "${aws_s3_bucket.r_resource_data_sync.arn}/*",
      "${aws_s3_bucket.r_athena_query_result.arn}/*",
      #"arn:aws:s3:::athena-dynamodb-connector-spill-bucket/*"
    ]
  }
  # statement {
  #   effect = "Allow"
  #   actions = ["lambda:InvokeFunction"]
  #   resources = ["arn:aws:lambda:ap-southeast-1:793820306412:function:dynamodbdata"]
  # }
}
#Create Lambda SSM-PatchScheduler IAM Policy
data "aws_iam_policy_document" "d_SSM_PatchScheduler" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "iam:GetRole"
    ]
    resources = [aws_iam_role.r_role_ssm_AutomationAdministrationRole.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = [aws_ses_email_identity.r_ses_email_id.arn, aws_ses_domain_identity.r_ses_domain_id.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

# ### Author Aruna Lilantha ###

# Create policy for Glue service IAM role 
data "aws_iam_policy_document" "d_s3Action" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PubObject"]
    resources = ["${aws_s3_bucket.r_resource_data_sync.arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.r_cmk.arn]
  }
}

data "aws_iam_policy_document" "d_GlueAction" {
  statement {
    effect  = "Allow"
    actions = ["glue:GetTable", "glue:UpdateTable"]
    resources = [

      "arn:aws:glue:${var.v_system_manager_aws_region}:${var.v_system_manager_aws_account}:catalog",
      "arn:aws:glue:${var.v_system_manager_aws_region}:${var.v_system_manager_aws_account}:database/${var.v_system_manager_glue_db}",
      "arn:aws:glue:${var.v_system_manager_aws_region}:${var.v_system_manager_aws_account}:table/${var.v_system_manager_glue_db}/aws_instanceinformation",
    ]
  }
}
