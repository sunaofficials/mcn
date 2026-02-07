module "vpc" {
  source = "../../../modules/vpc"
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name = "mcn-eks-dev"
  k8s_version  = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  node_groups = {
    default = {
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      instance_types = ["t3.micro"]
    }
  }
}
