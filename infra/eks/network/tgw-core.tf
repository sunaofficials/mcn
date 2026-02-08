resource "aws_ec2_transit_gateway" "main" {
  description = "Cisco-style Transit Gateway"

  default_route_table_association = false
  default_route_table_propagation = false

  tags = {
    Name = "mcn-tgw"
  }
}
