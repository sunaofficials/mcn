variable "cluster_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "node_groups" {
  type = any
}

variable "region" {
  type = string
}
