############################################
# Terraform & Provider
############################################
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
  region = var.aws_region
}

############################################
# Variables
############################################
variable "aws_region" {
  type        = string
  description = "AWS region (set in Terraform Cloud workspace)"
}

variable "hub_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "spoke_vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

############################################
# Data
############################################
data "aws_availability_zones" "available" {}

############################################
# HUB VPC
############################################
resource "aws_vpc" "hub" {
  cidr_block           = var.hub_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "hub-vpc"
  }
}

resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "hub-igw"
  }
}

############################################
# HUB PUBLIC SUBNETS (NAT lives here)
############################################
resource "aws_subnet" "hub_public" {
  count                   = 2
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = cidrsubnet(var.hub_vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "hub-public-${count.index}"
  }
}

############################################
# HUB PUBLIC ROUTE TABLE → IGW
############################################
resource "aws_route_table" "hub_public" {
  vpc_id = aws_vpc.hub.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hub.id
  }

  tags = {
    Name = "hub-public-rt"
  }
}

resource "aws_route_table_association" "hub_public" {
  count          = 2
  subnet_id      = aws_subnet.hub_public[count.index].id
  route_table_id = aws_route_table.hub_public.id
}

############################################
# HUB PRIVATE SUBNETS (TGW attachment)
############################################
resource "aws_subnet" "hub_private" {
  count             = 2
  vpc_id            = aws_vpc.hub.id
  cidr_block        = cidrsubnet(var.hub_vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "hub-private-${count.index}"
  }
}

############################################
# NAT GATEWAY (HUB)
############################################
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "hub" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.hub_public[0].id

  depends_on = [aws_internet_gateway.hub]

  tags = {
    Name = "hub-nat"
  }
}

############################################
# HUB PRIVATE ROUTE TABLE
# - Internet via NAT
# - Return traffic to Spoke via TGW (CRITICAL)
############################################
resource "aws_route_table" "hub_private" {
  vpc_id = aws_vpc.hub.id

  # Internet egress
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.hub.id
  }

  # RETURN PATH to Spoke (THIS FIXES EKS)
  route {
    cidr_block         = var.spoke_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "hub-private-rt"
  }
}

resource "aws_route_table_association" "hub_private" {
  count          = 2
  subnet_id      = aws_subnet.hub_private[count.index].id
  route_table_id = aws_route_table.hub_private.id
}


############################################
# SPOKE (EKS) VPC
############################################
resource "aws_vpc" "spoke" {
  cidr_block           = var.spoke_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-spoke-vpc"
  }
}

resource "aws_subnet" "spoke_private" {
  count             = 2
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet(var.spoke_vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "eks-private-${count.index}"
  }
}

############################################
# TRANSIT GATEWAY
############################################
resource "aws_ec2_transit_gateway" "main" {
  description                    = "core-tgw"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "core-tgw"
  }
}

############################################
# TGW ATTACHMENTS
############################################
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.hub.id
  subnet_ids         = aws_subnet.hub_private[*].id

  tags = {
    Name = "hub-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.spoke.id
  subnet_ids         = aws_subnet.spoke_private[*].id

  tags = {
    Name = "eks-spoke-attachment"
  }
}

############################################
# SPOKE PRIVATE ROUTE TABLE → TGW
############################################
resource "aws_route_table" "spoke_private" {
  vpc_id = aws_vpc.spoke.id

  # Local VPC traffic
  route {
    cidr_block = var.spoke_vpc_cidr
    gateway_id = "local"
  }

  # Internet via HUB (TGW → NAT → IGW)
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "eks-private-rt"
  }
}

resource "aws_route_table_association" "spoke_private" {
  count          = 2
  subnet_id      = aws_subnet.spoke_private[count.index].id
  route_table_id = aws_route_table.spoke_private.id
}

############################################
# OUTPUTS (for EKS workspace)
############################################
output "spoke_vpc_id" {
  value = aws_vpc.spoke.id
}

output "eks_private_subnet_ids" {
  value = aws_subnet.spoke_private[*].id
}
