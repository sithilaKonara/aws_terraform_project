#Get AWS account current effective Account ID, User ID, and ARN 
data "aws_caller_identity" "current" {}
#Get AWS account current Region 
data "aws_region" "current" {}
# Geting list of active availability zones in the region 
data "aws_availability_zones" "available" {
  state = "available"
}
