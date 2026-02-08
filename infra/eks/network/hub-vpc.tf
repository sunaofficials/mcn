resource "aws_vpc" "hub" {
  cidr_block           = var.hub_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "hub-vpc"
  }
}

resource "aws_subnet" "hub_public" {
  count             = 1
  vpc_id            = aws_vpc.hub.id
  cidr_block        = cidrsubnet(var.hub_vpc_cidr, 4, 0)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "hub-public"
  }
}
