resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "mcn-demo-ng"
  node_role_arn  = aws_iam_role.node_group.arn

  subnet_ids = data.terraform_remote_state.network.outputs.eks_private_subnet_ids


  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  tags = {
    Environment = "demo"
  }
}
