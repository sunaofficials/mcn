resource "aws_iam_role" "node_group" {
  name = "mcn-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "nodegroup_worker" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "nodegroup_cni" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "nodegroup_ecr" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "mcn-demo-ng"
  node_role_arn  = aws_iam_role.node_group.arn
  subnet_ids = data.aws_subnets.private.ids


  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  tags = {
    Name = "mcn-demo-nodegroup"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodegroup_worker,
    aws_iam_role_policy_attachment.nodegroup_cni,
    aws_iam_role_policy_attachment.nodegroup_ecr
  ]
}

