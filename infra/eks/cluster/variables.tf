variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "eks_cluster_version" {
  type        = string
  description = "Locked EKS version (standard support only)"
}
