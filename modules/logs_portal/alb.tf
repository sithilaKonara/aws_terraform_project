# Create target group for ALB
resource "aws_lb_target_group" "r_alb_target_group_ssm_logs_portal_80_blue" {
  name        = "${var.v_logs_portal_function_name}-Blue"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.v_logs_portal_vpc_id.id

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "r_alb_target_group_ssm_logs_portal_80_green" {
  name        = "${var.v_logs_portal_function_name}-Green"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.v_logs_portal_vpc_id.id
}

resource "aws_lb" "r_application_load_balancer_ssm_http" {
  name               = "ssm-patching"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.v_logs_portal_security_groups_id["ALB-SECURITY_GROUP"]}"]
  #### > Construct below subnets < ####
  subnets            = ["${var.v_logs_portal_subnet_public["ssm-vpn-public-01"]}", "${var.v_logs_portal_subnet_public["ssm-vpn-public-02"]}"]

  enable_deletion_protection = false

}

#### > Check whether aws_lb_listener also required < ####
resource "aws_lb_listener" "r_alb_ssm_listener" {
  load_balancer_arn = aws_lb.r_application_load_balancer_ssm_http.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.r_alb_target_group_ssm_logs_portal_80_blue.arn
  }
}