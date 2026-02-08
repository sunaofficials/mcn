resource "aws_vpc" "hub" {
  cidr_block = "10.100.0.0/16"

  tags = {
    Name = "hub-vpc"
  }
}

resource "aws_internet_gateway" "hub_igw" {
  vpc_id = aws_vpc.hub.id
}
