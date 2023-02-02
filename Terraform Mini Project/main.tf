terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#Provider
provider "aws" {
  region  = "us-east-1"
}

#Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "Name" = "main_vpc"
  }
}

#Create 3 public subnets
resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "public_subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    "Name" = "public_subnet2"
  }
}

resource "aws_subnet" "public_subnet3" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1c"
  tags = {
    "Name" = "public_subnet3"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "igw"
  }
}


#Create 3 Route Table
resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "rtable"
  }
}

#Route Table Association
#Association to subnet1
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.rtable.id
}
#Association to subnet2
resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.rtable.id
}
#Association to subnet3
resource "aws_route_table_association" "public_subnet3_association" {
  subnet_id      = aws_subnet.public_subnet3.id
  route_table_id = aws_route_table.rtable.id
}
