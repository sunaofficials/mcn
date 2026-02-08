output "spoke_vpc_id" {
  value = aws_vpc.spoke.id
}

output "spoke_private_subnet_ids" {
  value = aws_subnet.spoke_private[*].id
}

output "hub_vpc_id" {
  value = aws_vpc.hub.id
}

output "tgw_id" {
  value = aws_ec2_transit_gateway.main.id
}
