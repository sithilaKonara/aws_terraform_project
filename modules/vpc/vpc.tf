# Creating the VPC
resource "aws_vpc" "r_vpc" {
  cidr_block           = var.v_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.v_vpc_name
  }
}

# Creating required subnets
resource "aws_subnet" "r_ssm-vpn-private" {
  count             = length(var.v_vpc_private_subnet)
  vpc_id            = aws_vpc.r_vpc.id
  cidr_block        = var.v_vpc_private_subnet[count.index]
  availability_zone = var.v_vpc_availability_zones.names[count.index]

  tags = {
    Name = "${aws_vpc.r_vpc.tags.Name}-Private-0${count.index + 1}"
  }
}

resource "aws_subnet" "r_ssm-vpn-public" {
  count             = length(var.v_vpc_public_subnet)
  vpc_id            = aws_vpc.r_vpc.id
  cidr_block        = var.v_vpc_public_subnet[count.index]
  availability_zone = var.v_vpc_availability_zones.names[count.index]

  tags = {
    Name = "${aws_vpc.r_vpc.tags.Name}-Public-0${count.index + 1}"
  }
}
