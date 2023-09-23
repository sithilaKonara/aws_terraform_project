output "aws_vpc" {
  description = "Cidr block"
  value       = aws_vpc.main
}

output "private_subnets" {
  value = {
    SSM-VPN-PRIVATE-01 = "${aws_subnet.SSM-VPN-PRIVATE[0].id}",
    SSM-VPN-PRIVATE-02 = "${aws_subnet.SSM-VPN-PRIVATE[1].id}"
  }
}

output "public_subnets" {
  value = {
    SSM-VPN-PUBLIC-01 = "${aws_subnet.SSM-VPN-PUBLIC[0].id}",
    SSM-VPN-PUBLIC-02 = "${aws_subnet.SSM-VPN-PUBLIC[1].id}"
  }
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.SSM-IGW.id
}

output "aws_nat_gateway" {
  value = aws_nat_gateway.SSM-VPN-NGW.id
}

output "aws_vpn_gateway" {
  value = aws_vpn_gateway.SSM-VPN-VGW.id
}

output "aws_vpc_endpoint" {
  value = {
    LOGS-ENDPOINT        = "${aws_vpc_endpoint.LOGS-ENDPOINT.id}",
    ECR-API-ENDPOINT     = "${aws_vpc_endpoint.ECR-API-ENDPOINT.id}",
    ECR-DKR-ENDPOINT     = "${aws_vpc_endpoint.ECR-DKR-ENDPOINT.id}",
    API-GATEWAY-ENDPOINT = "${aws_vpc_endpoint.API-GATEWAY-ENDPOINT.id}",
    S3-GATEWAY-ENDPOINT  = "${aws_vpc_endpoint.S3-GATEWAY-ENDPOINT.id}",
    ECS-ENDPOINT         = "${aws_vpc_endpoint.ECS-ENDPOINT.id}"
  }
}

output "o_ssm_security_groups" {
  value = {
    ALB-SECURITY_GROUP         = "${aws_security_group.r_security_group_alb_vpn.id}",
    ECS-SERVICE-SECURITY_GROUP = "${aws_security_group.r_security_group_ecs_service_vpn.id}"
  }
}
