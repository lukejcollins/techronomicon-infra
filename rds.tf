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
    cidr_blocks = ["10.0.3.0/24", "82.40.44.205/32", "137.221.132.176/28", "137.221.132.192/28", "81.145.53.16/29", "81.145.54.184/29"]
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
