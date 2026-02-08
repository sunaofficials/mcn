resource "aws_iam_role" "eks_cluster" {
  name = "mcn-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "main" {
  name    = var.cluster_name
  version = var.eks_cluster_version

  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
  subnet_ids = data.aws_subnets.private.ids
}

  tags = {
    Environment = "demo"
    ManagedBy  = "Terraform"
  }
}

