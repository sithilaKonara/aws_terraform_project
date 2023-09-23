#Create ECS cluster "SSM"
resource "aws_ecs_cluster" "r_ssm_ecsCluster_name" {
  name = var.v_ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#Create base python image repository
resource "aws_ecr_repository" "r_ecr_python_image" {
  name                 = "ssm-python_base_img"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#Create ssm-tags_reset ECR
resource "aws_ecr_repository" "r_ssm_tagsReset_ecr" {
  name                 = lower(var.v_function_name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#Create ssm-tags_reset ECS task definition
resource "aws_ecs_task_definition" "r_ecsrd_ssm-tagsReset" {
  family                   = var.v_function_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = aws_iam_role.r_ssm_tagsReset_ecsTaskRole.arn
  execution_role_arn       = aws_iam_role.r_ssm_ecsTasExecutionRole.arn
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "${var.v_function_name}",
      "image": "${aws_ecr_repository.r_ssm_tagsReset_ecr.repository_url}:latest",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region" : "${var.v_aws_region}",
          "awslogs-group" : "/ecs/${var.v_function_name}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ]
TASK_DEFINITION  
}
