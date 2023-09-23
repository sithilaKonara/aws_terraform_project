#Create ssm-email_handler ECR
resource "aws_ecr_repository" "r_ecr_repository_ssm_email_handler" {
  name                 = lower(var.v_email_handler_function_name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#Create ssm-tags_reset ECS task definition
resource "aws_ecs_task_definition" "r_ecs_task_definition_ssm_email_handler" {
  family                   = var.v_email_handler_function_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = aws_iam_role.r_iam_role_ecs_task_ssm_email_handler.arn
  execution_role_arn       = var.v_email_handler_iam_roles["ecsTasExecutionRole"]
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "${var.v_email_handler_function_name}",
      "image": "${aws_ecr_repository.r_ecr_repository_ssm_email_handler.repository_url}:latest",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region" : "${var.v_email_handler_aws_region}",
          "awslogs-group" : "/aws/ecs/${var.v_email_handler_function_name}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ]
  TASK_DEFINITION
  depends_on = [
    aws_ecr_repository.r_ecr_repository_ssm_email_handler
  ]
}
