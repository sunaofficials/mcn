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
