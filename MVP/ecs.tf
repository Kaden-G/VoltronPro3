# AWS Provider Configuration
provider "aws" {
  alias  = "main"
  region = "us-east-1"  # Change to your desired region
}

# Create VPC
resource "aws_vpc" "voltron_vpc" {
  provider             = aws.main
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Voltron_VPC"
  }
}

# Create Internet Gateway (IGW)
resource "aws_internet_gateway" "voltron_igw" {
  provider = aws.main
  vpc_id   = aws_vpc.voltron_vpc.id
}

# Create Public Subnets
resource "aws_subnet" "public_subnet_a" {
  provider          = aws.main
  vpc_id            = aws_vpc.voltron_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # Adjust availability zone as needed

  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet_A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  provider          = aws.main
  vpc_id            = aws_vpc.voltron_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"  # Adjust availability zone as needed

  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet_B"
  }
}

# Associate Subnets with Route Tables
resource "aws_route_table_association" "public_subnet_a_association" {
  provider        = aws.main
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_association" {
  provider        = aws.main
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  provider = aws.main
  vpc_id   = aws_vpc.voltron_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.voltron_igw.id
  }
}

# IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "voltron_ecs_execution_role"

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
resource "aws_iam_role" "ecs_task_role" {
  name = "voltron_ecs_task_role"

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
resource "aws_iam_role_policy_attachment" "ecs_execution_role_ssm_full_access" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
resource "aws_iam_role_policy_attachment" "ecs_task_role_ssm_full_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_policy_attachment" "dynamodb_full_access" {
  name       = "dynamodb_full_access"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  provider = aws.main  # Specify the provider alias
  name     = "voltronecs"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/voltron-application"
  retention_in_days = 30  # Optional: Configure log retention policy (in days)
}

# ECS Task Definition for DynamoDB Access
resource "aws_ecs_task_definition" "dynamodb_task_definition" {
  provider = aws.main  # Specify the provider alias
  family                   = "dynamodb-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "dynamodb-container"
    image = "public.ecr.aws/n8b0e9r5/voltron-repo:latest"   # Replace with the provided Docker image URL for DynamoDB access
    # Add other container configuration as needed
  }])
}
resource "aws_lb" "voltron_alb" {
  name               = "voltron-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  enable_deletion_protection = false
  
  tags = {
    Name = "VoltronALB"
  }
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.voltron_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.voltron_tg.arn
  }
}
resource "aws_lb_target_group" "voltron_tg" {
  name     = "voltron-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.voltron_vpc.id
  target_type = "ip"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/health"
    protocol            = "HTTP"
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "voltron-alb-sg"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.voltron_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_ecs_service" "voltron_alb_service" {
  name            = "voltron-alb-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.alb_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.voltron_tg.arn
    container_name   = "alb-container"
    container_port   = 8080
    
  }

  depends_on = [
    aws_lb_listener.front_end,
  ]
}
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "voltron-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.voltron_vpc.id

  # Inbound traffic: Allow specific traffic to your container, e.g., HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic: Typically, allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS Tasks Security Group"
  }
}
# ECS Task Definition for ALB
resource "aws_ecs_task_definition" "alb_task_definition" {
  provider = aws.main  # Specify the provider alias
  family                   = "alb-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
   task_role_arn       = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  container_definitions = jsonencode([{
    name  = "alb-container"
    image = "public.ecr.aws/n8b0e9r5/voltron-repo:latest"  # Ensure this is your actual Docker image
    portMappings = [{
      containerPort = 8080,
      hostPort      = 8080,
      protocol      = "tcp"
    }]
        logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"

  }}}])
}

