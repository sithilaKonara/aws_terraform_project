# Public Route table 
resource "aws_route_table" "r_ssm-vpn-default" {
  vpc_id = aws_vpc.r_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.r_ssm-igw.id
  }
  tags = {
    Name = "${aws_vpc.r_vpc.tags.Name}-Default"
  }
}

# Private Route table
resource "aws_route_table" "r_ssm-vpn-private" {
  vpc_id = aws_vpc.r_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.r_ssm-vpn-ngw.id
  }
  tags = {
    Name = "${aws_vpc.r_vpc.tags.Name}-Private"
  }
}
#Create r_vpc route table association
resource "aws_main_route_table_association" "r_vpc_r_vpc_route_table" {
  vpc_id         = aws_vpc.r_vpc.id
  route_table_id = aws_route_table.r_ssm-vpn-default.id
}


# Create route table association
resource "aws_route_table_association" "r_private" {
  count          = length(aws_subnet.r_ssm-vpn-private)
  subnet_id      = element(aws_subnet.r_ssm-vpn-private.*.id, count.index)
  route_table_id = aws_route_table.r_ssm-vpn-private.id
}

resource "aws_route_table_association" "r_public" {
  count          = length(aws_subnet.r_ssm-vpn-public)
  subnet_id      = element(aws_subnet.r_ssm-vpn-public.*.id, count.index)
  route_table_id = aws_route_table.r_ssm-vpn-default.id #changed
}

# Enable route propgation for the private route table
resource "aws_vpn_gateway_route_propagation" "r_ssm_private" {
  vpn_gateway_id = aws_vpn_gateway.r_ssm-vpn-vgw.id
  route_table_id = aws_route_table.r_ssm-vpn-private.id
}

# VPC Endpoints subnet association
resource "aws_vpc_endpoint_subnet_association" "r_logs_endpoint" {
  count           = length(aws_subnet.r_ssm-vpn-private)
  vpc_endpoint_id = aws_vpc_endpoint.r_logs_endpoint.id
  subnet_id       = element(aws_subnet.r_ssm-vpn-private.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "r_s3-gateway-endpoint" {
  route_table_id  = aws_route_table.r_ssm-vpn-private.id
  vpc_endpoint_id = aws_vpc_endpoint.r_s3-gateway-endpoint.id
}

resource "aws_vpc_endpoint_subnet_association" "r_ecr_api_endpoint" {
  count           = length(aws_subnet.r_ssm-vpn-private)
  vpc_endpoint_id = aws_vpc_endpoint.r_ecr_api_endpoint.id
  subnet_id       = element(aws_subnet.r_ssm-vpn-private.*.id, count.index)
}

resource "aws_vpc_endpoint_subnet_association" "r_ecr-dkr-endpoint" {
  count           = length(aws_subnet.r_ssm-vpn-private)
  vpc_endpoint_id = aws_vpc_endpoint.r_ecr-dkr-endpoint.id
  subnet_id       = element(aws_subnet.r_ssm-vpn-private.*.id, count.index)
}

resource "aws_vpc_endpoint_subnet_association" "r_api-gateway-endpoint" {
  count           = length(aws_subnet.r_ssm-vpn-private)
  vpc_endpoint_id = aws_vpc_endpoint.r_api-gateway-endpoint.id
  subnet_id       = element(aws_subnet.r_ssm-vpn-private.*.id, count.index)
}

resource "aws_vpc_endpoint_subnet_association" "r_ecs-endpoint" {
  count           = length(aws_subnet.r_ssm-vpn-private)
  vpc_endpoint_id = aws_vpc_endpoint.r_ecs-endpoint.id
  subnet_id       = element(aws_subnet.r_ssm-vpn-private.*.id, count.index)
}
