# Hub TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "hub_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = { Name = "hub-rt" }
}

# Spoke TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "spoke_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = { Name = "spoke-rt" }
}

# Associate attachments
resource "aws_ec2_transit_gateway_route_table_association" "hub_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.eks_spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

# Spoke default route → Hub
resource "aws_ec2_transit_gateway_route" "spoke_default" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
}
