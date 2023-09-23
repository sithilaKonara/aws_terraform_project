# Create security group
resource "aws_security_group" "APIEndpointSecurityGroup" {
  name        = "APIEndpointSecurityGroup"
  description = "Allow connectivity to API Gateway VPC endpoint"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "APIEndpointSecurityGroup"
  }
}

# Create inbound rules
resource "aws_security_group_rule" "Allow_http_inbound" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.APIEndpointSecurityGroup.id
}


# Create outbound rules
resource "aws_security_group_rule" "Allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.APIEndpointSecurityGroup.id
}

# Create security group for ALB, allowing traffic to VPN (Logs Portal)
resource "aws_security_group" "r_security_group_alb_vpn" {
  name        = "LoadBalancerSecurityGroupVPN"
  description = "Allow connectivity to Loadbalancer on port 80 and 8080"
  vpc_id      = aws_vpc.main.id
}

# Create inbound rules to allow traffic to PORT 8080
resource "aws_security_group_rule" "r_security_group_rule_8080_alb_vpn" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  #### > Create below "v_public_subnet_for_vpn" < ####
  cidr_blocks       = var.v_logs_portal_public_subnets_vpn["SG_SOURCE_PORT_8080"]
  security_group_id = aws_security_group.r_security_group_alb_vpn.id

}

# Create inbound rules to allow traffic to PORT 80
resource "aws_security_group_rule" "r_security_group_rule_80_alb_vpn" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #### > Create below "v_public_subnet_for_vpn" < ####
  cidr_blocks       = var.v_logs_portal_public_subnets_vpn["SG_SOURCE_PORT_80"]
  security_group_id = aws_security_group.r_security_group_alb_vpn.id
}

resource "aws_security_group_rule" "r_security_group_rule_80_alb_outbound_vpn" {
  type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #### > Create below "v_public_subnet_for_vpn" < ####
  source_security_group_id = aws_security_group.r_security_group_ecs_service_vpn.id
  security_group_id        = aws_security_group.r_security_group_alb_vpn.id

}

# Create a security group for ECS Service (Logs Portal)
resource "aws_security_group" "r_security_group_ecs_service_vpn" {
  name        = "PatchingLogsPortalVPN"
  description = "Allow port 80 access to S3 logs portal"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "r_security_group_ecs_service_80_vpn" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #### > Create below "v_public_subnet_for_vpn" < ####
  source_security_group_id = aws_security_group.r_security_group_alb_vpn.id
  security_group_id        = aws_security_group.r_security_group_ecs_service_vpn.id

}

resource "aws_security_group_rule" "r_security_group_ecs_service_all_vpn" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.r_security_group_ecs_service_vpn.id

}
