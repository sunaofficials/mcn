terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

############################
# VPC
############################
resource "aws_vpc" "cisco_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cisco-vpc"
  }
}

############################
# Internet Gateway
############################
resource "aws_internet_gateway" "cisco_igw" {
  vpc_id = aws_vpc.cisco_vpc.id

  tags = {
    Name = "cisco-igw"
  }
}

############################
# Public Subnets
############################
resource "aws_subnet" "cisco_public_1" {
  vpc_id                  = aws_vpc.cisco_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "cisco-public-1"
  }
}

resource "aws_subnet" "cisco_public_2" {
  vpc_id                  = aws_vpc.cisco_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "cisco-public-2"
  }
}

############################
# Private Subnets (EKS Nodes)
############################
resource "aws_subnet" "cisco_private_1" {
  vpc_id            = aws_vpc.cisco_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "cisco-private-1"
  }
}

resource "aws_subnet" "cisco_private_2" {
  vpc_id            = aws_vpc.cisco_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "cisco-private-2"
  }
}

############################
# NAT Gateway
############################
resource "aws_eip" "cisco_nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "cisco_nat" {
  allocation_id = aws_eip.cisco_nat_eip.id
  subnet_id     = aws_subnet.cisco_public_1.id

  tags = {
    Name = "cisco-nat"
  }
}

############################
# Route Tables
############################
resource "aws_route_table" "cisco_public_rt" {
  vpc_id = aws_vpc.cisco_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cisco_igw.id
  }

  tags = {
    Name = "cisco-public-rt"
  }
}

resource "aws_route_table" "cisco_private_rt" {
  vpc_id = aws_vpc.cisco_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cisco_nat.id
  }

  tags = {
    Name = "cisco-private-rt"
  }
}

############################
# Route Table Associations
############################
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.cisco_public_1.id
  route_table_id = aws_route_table.cisco_public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.cisco_public_2.id
  route_table_id = aws_route_table.cisco_public_rt.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.cisco_private_1.id
  route_table_id = aws_route_table.cisco_private_rt.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.cisco_private_2.id
  route_table_id = aws_route_table.cisco_private_rt.id
}
