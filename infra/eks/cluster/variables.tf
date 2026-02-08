variable "cluster_name" {
  type    = string
}

variable "eks_cluster_version" {
  type    = string
  default = "1.32" # standard support
}

variable "aws_region" {
  type        = string
  description = "AWS region (workspace-level variable)"
}