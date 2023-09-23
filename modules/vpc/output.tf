output "o_aws_vpc" {
  description = "Cidr block"
  value       = aws_vpc.r_vpc
}

output "o_private_subnets" {
  value = {
    ssm-vpn-private-01 = "${aws_subnet.r_ssm-vpn-private[0].id}",
    ssm-vpn-private-02 = "${aws_subnet.r_ssm-vpn-private[1].id}"
  }
}

output "o_public_subnets" {
  value = {
    ssm-vpn-public-01 = "${aws_subnet.r_ssm-vpn-public[0].id}",
    ssm-vpn-public-02 = "${aws_subnet.r_ssm-vpn-public[1].id}"
  }
}

output "o_aws_internet_gateway" {
  value = aws_internet_gateway.r_ssm-igw.id
}

output "o_aws_nat_gateway" {
  value = aws_nat_gateway.r_ssm-vpn-ngw.id
}

output "o_aws_vpn_gateway" {
  value = aws_vpn_gateway.r_ssm-vpn-vgw.id
}

output "o_aws_vpc_endpoint" {
  value = {
    logs_endpoint        = "${aws_vpc_endpoint.r_logs_endpoint.id}",
    ecr_api_endpoint     = "${aws_vpc_endpoint.r_ecr_api_endpoint.id}",
    ecr-dkr-endpoint     = "${aws_vpc_endpoint.r_ecr-dkr-endpoint.id}",
    api-gateway-endpoint = "${aws_vpc_endpoint.r_api-gateway-endpoint.id}",
    s3-gateway-endpoint  = "${aws_vpc_endpoint.r_s3-gateway-endpoint.id}",
    ecs-endpoint         = "${aws_vpc_endpoint.r_ecs-endpoint.id}"
  }
}

output "o_o_ssm_security_groups" {
  value = {
    ALB-SECURITY_GROUP         = "${aws_security_group.r_security_group_alb_vpn.id}",
    ECS-SERVICE-SECURITY_GROUP = "${aws_security_group.r_security_group_ecs_service_vpn.id}"
  }
}
