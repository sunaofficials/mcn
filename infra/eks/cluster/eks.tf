resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.eks_cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = data.terraform_remote_state.network.outputs.eks_private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = {
    Environment = "demo"
    ManagedBy  = "Terraform"
  }
}
