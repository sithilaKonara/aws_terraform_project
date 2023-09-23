resource "aws_athena_data_catalog" "r_data_source" {
  name        = "dynamodbdata"
  description = "DynamoDb table connector"
  type        = "LAMBDA"

  parameters = {
    "function" = "arn:aws:lambda:${var.v_aws_region}:${var.v_aws_account}:function:dynamodbdata"
  }
}
