# Creating the internet gateway
resource "aws_internet_gateway" "r_ssm-igw" {
  vpc_id = aws_vpc.r_vpc.id

  tags = {
    Name = "${aws_vpc.r_vpc.tags.Name}-IGW"
  }
}

# Creating the elastic ip
resource "aws_eip" "SSM-EIP" {
  depends_on = [aws_internet_gateway.r_ssm-igw]
}

# Creating the nat gateway
resource "aws_nat_gateway" "r_ssm-vpn-ngw" {
  allocation_id = aws_eip.SSM-EIP.id
  subnet_id     = aws_subnet.r_ssm-vpn-public[1].id

  tags = {
    Name = "${aws_vpc.r_vpc.tags.Name}-NGW"
  }
  depends_on = [aws_internet_gateway.r_ssm-igw]
}

# Creating the VPN gateway
resource "aws_vpn_gateway" "r_ssm-vpn-vgw" {
  vpc_id          = aws_vpc.r_vpc.id
  amazon_side_asn = var.v_vpc_amazon_side_asn

  tags = {
    Name                              = "${aws_vpc.r_vpc.tags.Name}-VGW"
    "${var.v_vpc_naas_spoke_key}" = var.v_vpc_naas_spoke_value #Uncommenct this line in final deployment (VPN connection establishment)    
  }
}

