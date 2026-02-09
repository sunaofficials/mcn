terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

############################
# IAM Role for EKS Cluster
############################
resource "aws_iam_role" "cisco_eks_cluster_role" {
  name = "cisco-eks-cluster-role"

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

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cisco_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################
# IAM Role for Node Group
############################
resource "aws_iam_role" "cisco_eks_node_role" {
  name = "cisco-eks-node-role"

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

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.cisco_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.cisco_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.cisco_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################
# EKS Cluster
############################
resource "aws_eks_cluster" "cisco_cluster" {
  name     = "cisco-cluster"
  role_arn = aws_iam_role.cisco_eks_cluster_role.arn

  # ⚠️ If AWS rejects 1.32, change to 1.29 or 1.30
  version = "1.32"

  vpc_config {
    subnet_ids = [
      data.aws_subnet.cisco_private_1.id,
      data.aws_subnet.cisco_private_2.id
    ]

    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

############################
# Managed Node Group
############################
resource "aws_eks_node_group" "cisco_nodegroup" {
  cluster_name    = aws_eks_cluster.cisco_cluster.name
  node_group_name = "cisco-nodegroup"
  node_role_arn  = aws_iam_role.cisco_eks_node_role.arn
  subnet_ids     = [
    data.aws_subnet.cisco_private_1.id,
    data.aws_subnet.cisco_private_2.id
  ]

  instance_types = ["t3.medium"]
  disk_size      = 40

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]
}

############################
# Data Sources (Network)
############################
data "aws_subnet" "cisco_private_1" {
  filter {
    name   = "tag:Name"
    values = ["cisco-private-1"]
  }
}

data "aws_subnet" "cisco_private_2" {
  filter {
    name   = "tag:Name"
    values = ["cisco-private-2"]
  }
}
