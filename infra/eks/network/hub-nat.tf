resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "hub" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.hub_public.id

  tags = {
    Name = "hub-nat"
  }
}
