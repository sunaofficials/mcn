resource "aws_vpc" "spoke" {
  cidr_block           = var.spoke_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "spoke-vpc"
  }
}

resource "aws_subnet" "spoke_private" {
  count             = 2
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet(var.spoke_vpc_cidr, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "spoke-private-${count.index}"
  }
}
resource "aws_subnet" "eks_private" {
  count             = 2
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet(var.spoke_vpc_cidr, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}
