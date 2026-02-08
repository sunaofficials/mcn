resource "aws_subnet" "hub_public" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.100.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "hub-public"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "hub_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.hub_public.id

  tags = {
    Name = "hub-nat"
  }
}

resource "aws_route_table" "hub_public_rt" {
  vpc_id = aws_vpc.hub.id
}

resource "aws_route" "hub_public_internet" {
  route_table_id         = aws_route_table.hub_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub_igw.id
}

resource "aws_route_table_association" "hub_public_assoc" {
  subnet_id      = aws_subnet.hub_public.id
  route_table_id = aws_route_table.hub_public_rt.id
}
