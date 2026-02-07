module "this" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_irsa = true

  eks_managed_node_groups = var.node_groups
}
