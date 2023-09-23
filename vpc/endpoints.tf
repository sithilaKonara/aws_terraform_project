# Create VPC endpoints
resource "aws_vpc_endpoint" "LOGS-ENDPOINT" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.v_network_aws_region.name}.logs"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "Logs-Endpoint"
  }

  security_group_ids = [
    aws_security_group.APIEndpointSecurityGroup.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ECR-API-ENDPOINT" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.v_network_aws_region.name}.ecr.api"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "ECR-API-Endpoint"
  }

  security_group_ids = [
    aws_security_group.APIEndpointSecurityGroup.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ECR-DKR-ENDPOINT" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.v_network_aws_region.name}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "ECR-DKR-Endpoint"
  }

  security_group_ids = [
    aws_security_group.APIEndpointSecurityGroup.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "API-GATEWAY-ENDPOINT" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.v_network_aws_region.name}.execute-api"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "API-Gateway-Endpoint"
  }

  security_group_ids = [
    aws_security_group.APIEndpointSecurityGroup.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "S3-GATEWAY-ENDPOINT" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.v_network_aws_region.name}.s3"
  tags = {
    Name = "S3-Gateway-Endpoint"
  }
}

resource "aws_vpc_endpoint" "ECS-ENDPOINT" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.v_network_aws_region.name}.ecs"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "ECS-Endpoint"
  }

  security_group_ids = [
    aws_security_group.APIEndpointSecurityGroup.id,
  ]

  private_dns_enabled = true
}
