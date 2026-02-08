########################################
# Network CIDRs (environment-specific)
########################################

variable "hub_vpc_cidr" {
  type        = string
  description = "CIDR block for hub VPC"
}

variable "spoke_vpc_cidr" {
  type        = string
  description = "CIDR block for EKS spoke VPC"
}
