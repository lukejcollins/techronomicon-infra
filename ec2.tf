# Security group for instance
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.40.44.205/32", "137.221.132.176/28", "137.221.132.192/28", "81.145.53.16/29", "81.145.54.184/29", "18.202.216.48/29"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.EC2_SG_RESOURCES_BOOL ? [
      "173.245.48.0/20",
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "141.101.64.0/18",
      "108.162.192.0/18",
      "190.93.240.0/20",
      "188.114.96.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17",
      "162.158.0.0/15",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "172.64.0.0/13",
      "131.0.72.0/22",
    ] : ["0.0.0.0/0"
    ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.EC2_SG_RESOURCES_BOOL ? [
      "173.245.48.0/20",
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "141.101.64.0/18",
      "108.162.192.0/18",
      "190.93.240.0/20",
      "188.114.96.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17",
      "162.158.0.0/15",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "172.64.0.0/13",
      "131.0.72.0/22",
    ] : ["0.0.0.0/0"
    ]
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
  ami           = "ami-0a2202cf4c36161a1"
  instance_type = "t2.micro"

  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name

  subnet_id = aws_subnet.my_public_subnet1.id

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  key_name = "techronomicon-ssh-key"
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install python3-pip git -y
    pip3 install ansible
    
  EOF

  tags = {
    Name = "techronomicon-instance"
  }
}
