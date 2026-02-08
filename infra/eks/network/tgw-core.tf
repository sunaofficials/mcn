resource "aws_ec2_transit_gateway" "main" {
  description = "MCN core TGW"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "mcn-core-tgw"
  }
}
