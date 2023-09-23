# Creates/manages KMS CMK
resource "aws_kms_key" "r_cmk" {
  description         = "Key used to encrypt SSM automation data"
  policy              = data.aws_iam_policy_document.d_cmk_policy.json
  enable_key_rotation = true
}
# Add an alias to the key
resource "aws_kms_alias" "r_cmk_aliases" {
  name          = "alias/${var.v_system_manager_cmk_aliases}"
  target_key_id = aws_kms_key.r_cmk.id
}
