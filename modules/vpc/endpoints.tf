# Create VPC endpoints
resource "aws_vpc_endpoint" "r_logs_endpoint" {
  vpc_id            = aws_vpc.r_vpc.id
  service_name      = "com.amazonaws.${var.v_vpc_region.name}.logs"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "logs_endpoint"
  }

  security_group_ids = [
    aws_security_group.r_api_endpoint_security_group.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "r_ecr_api_endpoint" {
  vpc_id            = aws_vpc.r_vpc.id
  service_name      = "com.amazonaws.${var.v_vpc_region.name}.ecr.api"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "ecr_api_endpoint"
  }

  security_group_ids = [
    aws_security_group.r_api_endpoint_security_group.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "r_ecr-dkr-endpoint" {
  vpc_id            = aws_vpc.r_vpc.id
  service_name      = "com.amazonaws.${var.v_vpc_region.name}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "ecr-dkr-endpoint"
  }

  security_group_ids = [
    aws_security_group.r_api_endpoint_security_group.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "r_api-gateway-endpoint" {
  vpc_id            = aws_vpc.r_vpc.id
  service_name      = "com.amazonaws.${var.v_vpc_region.name}.execute-api"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "api-gateway-endpoint"
  }

  security_group_ids = [
    aws_security_group.r_api_endpoint_security_group.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "r_s3-gateway-endpoint" {
  vpc_id       = aws_vpc.r_vpc.id
  service_name = "com.amazonaws.${var.v_vpc_region.name}.s3"
  tags = {
    Name = "s3-gateway-endpoint"
  }
}

resource "aws_vpc_endpoint" "r_ecs-endpoint" {
  vpc_id            = aws_vpc.r_vpc.id
  service_name      = "com.amazonaws.${var.v_vpc_region.name}.ecs"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "ecs-endpoint"
  }

  security_group_ids = [
    aws_security_group.r_api_endpoint_security_group.id,
  ]

  private_dns_enabled = true
}
