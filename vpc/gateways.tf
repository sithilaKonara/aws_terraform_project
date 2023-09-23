# Creating the internet gateway
resource "aws_internet_gateway" "SSM-IGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${aws_vpc.main.tags.Name}-IGW"
  }
}

# Creating the elastic ip
resource "aws_eip" "SSM-EIP" {
  depends_on = [aws_internet_gateway.SSM-IGW]
}

# Creating the nat gateway
resource "aws_nat_gateway" "SSM-VPN-NGW" {
  allocation_id = aws_eip.SSM-EIP.id
  subnet_id     = aws_subnet.SSM-VPN-PUBLIC[1].id

  tags = {
    Name = "${aws_vpc.main.tags.Name}-NGW"
  }
  depends_on = [aws_internet_gateway.SSM-IGW]
}

# Creating the VPN gateway
resource "aws_vpn_gateway" "SSM-VPN-VGW" {
  vpc_id          = aws_vpc.main.id
  amazon_side_asn = var.v_network_amazon_side_asn

  tags = {
    Name                              = "${aws_vpc.main.tags.Name}-VGW"
    "${var.v_network_naas_spoke_key}" = var.v_network_naas_spoke_value #Uncommenct this line in final deployment (VPN connection establishment)    
  }
}

