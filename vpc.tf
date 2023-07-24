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
