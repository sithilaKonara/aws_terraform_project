# Getting list of active availability zones in the region 
data "aws_availability_zones" "available" {
  state = "available"
}

# Creating the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpn_name
  }
}

# Creating required subnets
resource "aws_subnet" "SSM-VPN-PRIVATE" {
  count             = length(var.private)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private[count.index]
  availability_zone = var.v_network_aws_availability_zones.names[count.index]

  tags = {
    Name = "${aws_vpc.main.tags.Name}-Private-0${count.index + 1}"
  }
}

resource "aws_subnet" "SSM-VPN-PUBLIC" {
  count             = length(var.public)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public[count.index]
  availability_zone = var.v_network_aws_availability_zones.names[count.index]

  tags = {
    Name = "${aws_vpc.main.tags.Name}-Public-0${count.index + 1}"
  }
}
