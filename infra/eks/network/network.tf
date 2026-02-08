########################################
# DATA
########################################
data "aws_availability_zones" "available" {}

########################################
# VARIABLES
########################################
variable "hub_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "spoke_vpc_cidr" {
  default = "10.10.0.0/16"
}

########################################
# HUB VPC
########################################
resource "aws_vpc" "hub" {
  cidr_block           = var.hub_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "hub-vpc"
  }
}

resource "aws_subnet" "hub_public" {
  count                   = 2
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = cidrsubnet(var.hub_vpc_cidr, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "hub-public-${count.index}"
  }
}


resource "aws_subnet" "hub_private" {
  count             = 2
  vpc_id            = aws_vpc.hub.id
  cidr_block        = cidrsubnet(var.hub_vpc_cidr, 4, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "hub-private-${count.index}"
  }
}


########################################
# HUB IGW + NAT
########################################
resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "hub" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.hub_public[0].id

  depends_on = [aws_internet_gateway.hub]
}

########################################
# SPOKE (EKS) VPC
########################################
resource "aws_vpc" "spoke" {
  cidr_block           = var.spoke_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-spoke-vpc"
  }
}

resource "aws_subnet" "eks_private" {
  count             = 2
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet(var.spoke_vpc_cidr, 4, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "eks-private-${count.index}"
  }
}


########################################
# TRANSIT GATEWAY
########################################
resource "aws_ec2_transit_gateway" "main" {
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "core-tgw"
  }
}

########################################
# TGW ATTACHMENTS
########################################
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.hub.id
  subnet_ids         = aws_subnet.hub_private[*].id

  tags = {
    Name = "hub-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "eks_spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.spoke.id
  subnet_ids         = aws_subnet.eks_private[*].id

  tags = {
    Name = "eks-spoke-attachment"
  }
}

########################################
# SPOKE ROUTING (EKS → TGW)
########################################
resource "aws_route_table" "eks_private" {
  vpc_id = aws_vpc.spoke.id
}

resource "aws_route" "eks_default_to_tgw" {
  route_table_id         = aws_route_table.eks_private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route_table_association" "eks_private" {
  count          = length(aws_subnet.eks_private)
  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.eks_private.id
}

########################################
# HUB ROUTING (TGW → NAT)
########################################
resource "aws_route_table" "hub_private" {
  vpc_id = aws_vpc.hub.id
}

resource "aws_route" "hub_default_to_nat" {
  route_table_id         = aws_route_table.hub_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.hub.id
}

resource "aws_route_table_association" "hub_private" {
  count          = length(aws_subnet.hub_private)
  subnet_id      = aws_subnet.hub_private[count.index].id
  route_table_id = aws_route_table.hub_private.id
}