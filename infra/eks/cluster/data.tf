data "aws_vpc" "hub" {
  filter {
    name   = "tag:Name"
    values = ["mcn-hub-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub.id]
  }
}

data "aws_availability_zones" "available" {}
