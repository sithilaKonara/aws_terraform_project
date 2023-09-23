#Create base php-apache image repository
resource "aws_ecr_repository" "r_ecr_php_apache_image" {
  name                 = "ssm-php-apache_base_img"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
#Create ssm-log portal ECR
resource "aws_ecr_repository" "r_ecr_repository_ssm_logs_portal" {
  name                 = lower(var.v_logs_portal_function_name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#Create ssm-tags_reset ECS task definition
resource "aws_ecs_task_definition" "r_ecs_task_definition_ssm_logs_portal" {
  family                   = var.v_logs_portal_function_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = aws_iam_role.r_iam_role_ecs_task_role.arn
  execution_role_arn       = var.v_logs_portal_ecsTaskExecutionRole["ecsTasExecutionRole"]
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "${var.v_logs_portal_function_name}",
      "image": "${aws_ecr_repository.r_ecr_repository_ssm_logs_portal.repository_url}:latest",
      "essential": true,
      "portMappings" : [{
          "containerPort" : 80,
          "hostPort"      : 80
        }],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region" : "${var.v_logs_portal_region}",
          "awslogs-group" : "/ecs/${var.v_logs_portal_function_name}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ]
  TASK_DEFINITION
  depends_on = [
    aws_ecr_repository.r_ecr_repository_ssm_logs_portal
  ]
}
# Create ECS service
resource "aws_ecs_service" "r_ecs_service_ssm_logs_portal" {
  name                              = var.v_logs_portal_function_name
  cluster                           = var.v_logs_portal_ecs_cluster_name                                # Check wether we can get the ID of the cluster.
  task_definition                   = aws_ecs_task_definition.r_ecs_task_definition_ssm_logs_portal.arn # Check this task definition number is picked.
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.r_alb_target_group_ssm_logs_portal_80_blue.arn
    container_name   = var.v_logs_portal_function_name
    container_port   = 80
  }

  network_configuration {
    subnets = ["${var.v_logs_portal_subnet_private["ssm-vpn-private-01"]}", "${var.v_logs_portal_subnet_private["ssm-vpn-private-02"]}"] # Check whether Private subnets populated here
    #### > Create a security group < ####
    security_groups  = ["${var.v_logs_portal_security_groups_id["ECS-SERVICE-SECURITY_GROUP"]}"]
    assign_public_ip = false
  }

  # InvalidECSServiceException: Deployment group's ECS service must be configured for a CODE_DEPLOY deployment controller
  # If recieve above error disable "deployment_controller" code segment and deploy then uncomment the code segment and redeploy
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [
    # aws_codedeploy_app.r_codedeploy_app_logs_portal,
    # aws_codedeploy_deployment_group.r_codedeploy_group_logs_portal,
    aws_codepipeline.r_codepipeline_ssm_logs_portal
  ]
}
