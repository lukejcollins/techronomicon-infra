# Provider configuration for AWS in the "eu-west-1" region
provider "aws" {
  region = "eu-west-1"
}

# Definition of an AWS VPC resource
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}

# Definition of an AWS subnet resource
resource "aws_subnet" "my_public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "my_public_subnet"
  }
}

# Definition of an AWS internet gateway resource
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}
