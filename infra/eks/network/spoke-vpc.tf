resource "aws_vpc" "spoke" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "eks-spoke-vpc"
  }
}

resource "aws_subnet" "eks_private" {
  count             = 2
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet("10.10.0.0/16", 8, count.index)
  availability_zone = "${var.aws_region}${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "eks-private-${count.index}"
  }
}
