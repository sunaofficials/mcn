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

variable "cluster_name" {
  type        = string
  description = "EKS cluster name (passed from Terraform Cloud)"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "demo"
}
