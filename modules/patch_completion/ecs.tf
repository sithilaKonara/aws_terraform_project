resource "aws_ecr_repository" "r_patch_completion" {
  name                 = lower(var.v_patch_completion_function_name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "r_patch_completion" {
  family                   = var.v_patch_completion_function_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.v_patch_completion_ecsTaskExecutionRole["ecsTasExecutionRole"]
  task_role_arn            = aws_iam_role.r_ecs_patch_completion_role.arn
  container_definitions    = <<TASK_DEFINITION
    [
        {
          "name": "${var.v_patch_completion_function_name}",
          "image": "${aws_ecr_repository.r_patch_completion.repository_url}:latest",
          "essential": true,
          "logConfiguration": {
              "logDriver": "awslogs",
              "options": {
                "awslogs-region" : "${var.v_patch_completion_reagion}",
                "awslogs-group" : "/ecs/${var.v_patch_completion_function_name}",
                "awslogs-stream-prefix" : "ecs"
              }
            }
        }
    ]
TASK_DEFINITION
}