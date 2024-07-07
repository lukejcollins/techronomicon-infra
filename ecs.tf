# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "techronomicon-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "techronomicon-family"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = <<DEFINITION
  [
    {
      "name": "techronomicon-container",
      "image": "ghcr.io/lukejcollins/techronomicon/techronomicon:${var.use_latest ? "latest" : "preprod"}",
      "cpu": 128,
      "memory": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8000,
          "hostPort": 8000
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group" : "${aws_cloudwatch_log_group.example.name}",
              "awslogs-region" : "eu-west-1",
              "awslogs-stream-prefix": "ecs"
          }
      }
    }
  ]
  DEFINITION
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "techronomicon-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "EC2"
}
