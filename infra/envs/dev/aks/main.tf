module "aks" {
  source = "../../../modules/aks"

  cluster_name = "mcn-aks-dev"
  location     = "south india"
}
