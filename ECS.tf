provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "voltorn_ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com",
      },
    }],
  })
}

# Attach an IAM policy to the ECS Execution Role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "voltronecs"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "my-container"
    image = "nginx:latest"   # Replace with your Docker image URL
    portMappings = [{
      containerPort = 80,
      hostPort      = 80,
    }]
  }])
}

# ECS Service
resource "aws_ecs_service" "my_service" {
  name            = "voltronecs"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = ["subnet-0057664ba21bd4735"]  # Replace with your subnet IDs
    security_groups = ["sg-0d1ccb3f21d0b03d9"]  # Replace with your security group IDs
  }
}
