# Public Route table 
resource "aws_route_table" "SSM-VPN-DEFAULT" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.SSM-IGW.id
  }
  tags = {
    Name = "${aws_vpc.main.tags.Name}-Default"
  }
}

# resource "aws_default_route_table" "SSM-VPN-DEFAULT" {
#   default_route_table_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.SSM-IGW.id
#   }
#   tags = {
#     Name = "${aws_vpc.main.tags.Name}-Defaultttttt"
#   }
# }

# Private Route table
resource "aws_route_table" "SSM-VPN-PRIVATE" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.SSM-VPN-NGW.id
  }
  tags = {
    Name = "${aws_vpc.main.tags.Name}-Private"
  }
}
#Create main route table association
resource "aws_main_route_table_association" "r_vpc_main_route_table" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.SSM-VPN-DEFAULT.id
}


# Create route table association
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.SSM-VPN-PRIVATE)
  subnet_id      = element(aws_subnet.SSM-VPN-PRIVATE.*.id, count.index)
  route_table_id = aws_route_table.SSM-VPN-PRIVATE.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.SSM-VPN-PUBLIC)
  subnet_id      = element(aws_subnet.SSM-VPN-PUBLIC.*.id, count.index)
  route_table_id = aws_route_table.SSM-VPN-DEFAULT.id #changed
}

# Enable route propgation for the private route table
resource "aws_vpn_gateway_route_propagation" "SSM-PRIVATE" {
  vpn_gateway_id = aws_vpn_gateway.SSM-VPN-VGW.id
  route_table_id = aws_route_table.SSM-VPN-PRIVATE.id
}

# VPC Endpoints subnet association
resource "aws_vpc_endpoint_subnet_association" "LOGS-ENDPOINT" {
  count           = length(aws_subnet.SSM-VPN-PRIVATE)
  vpc_endpoint_id = aws_vpc_endpoint.LOGS-ENDPOINT.id
  subnet_id       = element(aws_subnet.SSM-VPN-PRIVATE.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "S3-GATEWAY-ENDPOINT" {
  route_table_id  = aws_route_table.SSM-VPN-PRIVATE.id
  vpc_endpoint_id = aws_vpc_endpoint.S3-GATEWAY-ENDPOINT.id
}

resource "aws_vpc_endpoint_subnet_association" "ECR-API-ENDPOINT" {
  count           = length(aws_subnet.SSM-VPN-PRIVATE)
  vpc_endpoint_id = aws_vpc_endpoint.ECR-API-ENDPOINT.id
  subnet_id       = element(aws_subnet.SSM-VPN-PRIVATE.*.id, count.index)
}

resource "aws_vpc_endpoint_subnet_association" "ECR-DKR-ENDPOINT" {
  count           = length(aws_subnet.SSM-VPN-PRIVATE)
  vpc_endpoint_id = aws_vpc_endpoint.ECR-DKR-ENDPOINT.id
  subnet_id       = element(aws_subnet.SSM-VPN-PRIVATE.*.id, count.index)
}

resource "aws_vpc_endpoint_subnet_association" "API-GATEWAY-ENDPOINT" {
  count           = length(aws_subnet.SSM-VPN-PRIVATE)
  vpc_endpoint_id = aws_vpc_endpoint.API-GATEWAY-ENDPOINT.id
  subnet_id       = element(aws_subnet.SSM-VPN-PRIVATE.*.id, count.index)
}

resource "aws_vpc_endpoint_subnet_association" "ECS-ENDPOINT" {
  count           = length(aws_subnet.SSM-VPN-PRIVATE)
  vpc_endpoint_id = aws_vpc_endpoint.ECS-ENDPOINT.id
  subnet_id       = element(aws_subnet.SSM-VPN-PRIVATE.*.id, count.index)
}
