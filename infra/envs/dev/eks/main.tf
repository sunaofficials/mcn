module "eks" {
  source = "../../../modules/eks"

  name = var.cluster_name
  kubernetes_version  = var.k8s_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  node_groups = var.node_groups
}

