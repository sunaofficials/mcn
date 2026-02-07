variable "aws_region" {
  type        = string
  default     = "ap-south-2"
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  default     = "mcn-eks-demo"
  description = "EKS cluster name"
}

variable "eks_cluster_version" {
  type        = string
  default     = "1.32"

  description = <<EOT
Locked EKS version.

Reason:
- Standard support = $0.10/hour
- Extended support = $0.60/hour
We intentionally stay in standard support for demo environments.
EOT
}

variable "region" {
  type        = string
  default     = null
  description = "Terraform Cloud injected region (mapped internally)"
}

