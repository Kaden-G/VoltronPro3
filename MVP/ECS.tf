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

# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  provider = aws.main  # Specify the provider alias
  name     = "voltronecs"
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

# ECS Task Definition for ALB
resource "aws_ecs_task_definition" "alb_task_definition" {
  provider = aws.main  # Specify the provider alias
  family                   = "alb-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "alb-container"
    image = "public.ecr.aws/n8b0e9r5/voltron-repo:latest"   # Replace with the provided Docker image URL for ALB
    # Add other container configuration as needed
  }])
}
