# #Create base python image repository
# resource "aws_ecr_repository" "r_ecr_python_image" {
#   name                 = "ssm-python_base_img"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

#Create image repository for SSM Reporting
resource "aws_ecr_repository" "r_ecr_ssm_reporting" {
  name                 = lower(var.v_function_name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#Create Task Definition for SSM Reporting
resource "aws_ecs_task_definition" "r_ssm_store_patch_data" {
  family                   = var.v_function_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.v_ecsTaskExecutionRole["ecsTasExecutionRole"]
  task_role_arn            = aws_iam_role.r_ecs_task_store_patch_data_role.arn

  container_definitions = <<TASK_DEFINITION
  [
    {
      "name": "${var.v_function_name}",
      "image": "${aws_ecr_repository.r_ecr_ssm_reporting.repository_url}:latest",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region" : "${var.v_aws_region}",
          "awslogs-group" : "/ecs/${var.v_function_name}",
          "awslogs-stream-prefix" : "ecs",
          "awslogs-create-group": "true"
        }
      }
    }
  ]
TASK_DEFINITION  
}   
