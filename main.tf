# Provider configuration for AWS in the "eu-west-1" region
provider "aws" {
  region = "eu-west-1"
}

# Set up state file in S3 bucket
terraform {
  backend "s3" {
    bucket = "vtksrz06s3d0kam8w1ki86osghfzfvxd"
    key    = "dev/techronomicon/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Definition of an AWS VPC resource
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my_vpc"
  }
}

# Definition of an AWS subnet resource
resource "aws_subnet" "my_public_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"  # Use a different CIDR block for my_public_subnet1
  availability_zone = "eu-west-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "my_public_subnet1"
  }
}

resource "aws_subnet" "my_public_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "my_public_subnet2"
  }
}

# Definition of an AWS internet gateway resource
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# Create a custom route table in your VPC
resource "aws_route_table" "custom" {
  vpc_id = aws_vpc.my_vpc.id

  # Add a route to the Internet Gateway for all non-local traffic
  route {
    cidr_block = "0.0.0.0/0" # For all non-local traffic
    gateway_id = aws_internet_gateway.my_igw.id # The Internet Gateway to route traffic to
  }

  tags = {
    Name = "my_route_table"
  }
}

# Associate the first public subnet with the custom route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_public_subnet1.id # The ID of the subnet to associate with the route table
  route_table_id = aws_route_table.custom.id # The ID of the custom route table
}

# Associate the second public subnet with the custom route table
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.my_public_subnet2.id # The ID of the subnet to associate with the route table
  route_table_id = aws_route_table.custom.id # The ID of the custom route table
}


# Variables for your database username and password
variable "DB_USERNAME" {}
variable "DB_PASSWORD" {}

# A security group for your RDS instance
resource "aws_security_group" "sg" {
  name        = "postgres"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id  # Associates this security group with your VPC

  # Inbound rule: allows traffic from your IP address to port 5432 (PostgreSQL)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]
  }

  # Outbound rule: allows all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# A DB subnet group for your RDS instance
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my_db_subnet_group"
  subnet_ids = [
    aws_subnet.my_public_subnet1.id,
    aws_subnet.my_public_subnet2.id,
  ]  # Associates multiple subnets with your DB subnet group

  tags = {
    Name = "my_db_subnet_group"
  }
}

# The RDS instance
resource "aws_db_instance" "db" {
  identifier_prefix     = "postgres-db"
  engine                = "postgres"
  engine_version        = "13"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  username              = var.DB_USERNAME  # Uses the DB_USERNAME variable for the DB username
  password              = var.DB_PASSWORD  # Uses the DB_PASSWORD variable for the DB password
  vpc_security_group_ids = [aws_security_group.sg.id]  # Associates this RDS instance with the security group
  db_subnet_group_name  = aws_db_subnet_group.my_db_subnet_group.name  # Associates this RDS instance with the DB subnet group

  apply_immediately     = true
  skip_final_snapshot   = true  # Skips creating a final DB snapshot when the DB instance is deleted

  publicly_accessible   = false
}

# Variables for SSM
variable "TECHRONOMICON_ACCESS_KEY_ID" {}
variable "TECHRONOMICON_SECRET_ACCESS_KEY" {}
variable "TECHRONOMICON_STORAGE_BUCKET_NAME" {}
variable "DJANGO_SECRET_KEY" {}
variable "TECHRONOMICON_RDS_DB_NAME" {}

# Define variables for SSM
locals {
  techronomicon_parameters = {
    TECHRONOMICON_ACCESS_KEY_ID     = var.TECHRONOMICON_ACCESS_KEY_ID
    TECHRONOMICON_SECRET_ACCESS_KEY = var.TECHRONOMICON_SECRET_ACCESS_KEY
    TECHRONOMICON_RDS_USERNAME      = var.DB_USERNAME
    TECHRONOMICON_RDS_PASSWORD      = var.DB_PASSWORD
    TECHRONOMICON_STORAGE_BUCKET_NAME = var.TECHRONOMICON_STORAGE_BUCKET_NAME
    DJANGO_SECRET_KEY               = var.DJANGO_SECRET_KEY
    TECHRONOMICON_RDS_DB_NAME       = var.TECHRONOMICON_RDS_DB_NAME
    TECHRONOMICON_RDS_HOST          = aws_db_instance.db.endpoint
  }
}

# Create parameters in SSM
resource "aws_ssm_parameter" "techronomicon_parameters" {
  for_each = local.techronomicon_parameters

  name  = "/${each.key}"
  type  = "String"
  value = each.value
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# This block creates an inline IAM role policy named "ecs_task_execution_role_policy" for the role specified
resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "ecs_task_execution_role_policy"
  role   = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource  = "*"
      }
    ]
  })
}

# This block creates a managed IAM policy called "parameter_store_access"
resource "aws_iam_policy" "parameter_store_access" {
  name        = "parameter_store_access"
  description = "Policy to allow ECS tasks to access specific parameters in Parameter Store"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-1:777431414664:parameter/DJANGO_SECRET_KEY",
        "arn:aws:ssm:eu-west-1:777431414664:parameter/TECHRONOMICON_ACCESS_KEY_ID",
        "arn:aws:ssm:eu-west-1:777431414664:parameter/TECHRONOMICON_RDS_DB_NAME",
        "arn:aws:ssm:eu-west-1:777431414664:parameter/TECHRONOMICON_RDS_HOST",
        "arn:aws:ssm:eu-west-1:777431414664:parameter/TECHRONOMICON_RDS_PASSWORD",
        "arn:aws:ssm:eu-west-1:777431414664:parameter/TECHRONOMICON_RDS_USERNAME",
        "arn:aws:ssm:eu-west-1:777431414664:parameter/TECHRONOMICON_SECRET_ACCESS_KEY",
        "arn:aws:ssm:eu-west-1:777431414664:parameter/TECHRONOMICON_STORAGE_BUCKET_NAME"
      ]
    }
  ]
}
EOF
}

# Attach the IAM policy to the role
resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.parameter_store_access.arn
}

# Security group for instance
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.46.59.172/32"]
  }

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance_sg"
  }
}

# Create IAM role
resource "aws_iam_role" "ecs_role" {
  name = "ecs_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach AmazonEC2ContainerServiceforEC2Role managed policy
resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_role.name
}

# EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0fb2f0b847d44d4f0"
  instance_type = "t2.micro"

  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name

  subnet_id = aws_subnet.my_public_subnet1.id

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  key_name = "techronomicon-ssh"
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /etc/ecs
    echo "ECS_CLUSTER=techronomicon-cluster" > /etc/ecs/ecs.config
    dnf install ecs-init nginx python3-pip -y
    systemctl enable --now --no-block ecs.service
    pip3 install --yes certbot
  EOF

  tags = {
    Name = "techronomicon-instance"
  }
}

# Store EC2 IP in Parameter Store
resource "aws_ssm_parameter" "public_ip" {
  name        = "/TECHRONOMICON_IP"
  description = "Public IP of the EC2 instance"
  type        = "String"
  value       = aws_instance.example.public_ip
}

# Create an s3 bucket for the application static
resource "aws_s3_bucket" "techronomicon" {
  bucket = var.TECHRONOMICON_STORAGE_BUCKET_NAME
}

resource "aws_s3_bucket_cors_configuration" "techronomicon_cors" {
  bucket = aws_s3_bucket.techronomicon.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "techronomicon_policy" {
  bucket = aws_s3_bucket.techronomicon.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::techronomicon_static/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "techronomicon" {
  bucket = aws_s3_bucket.techronomicon.id

  block_public_acls   = false
  block_public_policy = false
}

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "techronomicon-cluster"
}

# Create an AWS CloudWatch Log Group named "techronomicon"
resource "aws_cloudwatch_log_group" "example" {
  name = "techronomicon"
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
      "image": "ghcr.io/lukejcollins/techronomicon/techronomicon:latest",
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

# Create an AWS Route 53 Zone for the domain "lukecollins.dev"
resource "aws_route53_zone" "my_domain" {
  name = "lukecollins.dev"
}

# Create a Route 53 record for the domain "lukecollins.dev"
resource "aws_route53_record" "my_domain_a" {
  zone_id = aws_route53_zone.my_domain.zone_id
  name    = "lukecollins.dev"
  type    = "A"
  ttl     = 300
  records = [aws_instance.example.public_ip]
}
