# Security group for instance
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.40.44.205/32", "137.221.132.176/28", "137.221.132.192/28", "81.145.53.16/29", "81.145.54.184/29"]
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

# EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0fb2f0b847d44d4f0"
  instance_type = "t2.micro"

  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name

  subnet_id = aws_subnet.my_public_subnet1.id

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  key_name = "techronomicon-ssh-key"
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /etc/ecs
    echo "ECS_CLUSTER=techronomicon-cluster" > /etc/ecs/ecs.config
    dnf install ecs-init nginx python3-pip -y
    systemctl enable --now --no-block ecs.service
    pip3 install certbot certbot-nginx
  EOF

  tags = {
    Name = "techronomicon-instance"
  }
}
