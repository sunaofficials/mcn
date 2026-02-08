data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "mcnssn"
    workspaces = {
      name = "mcn-eks-network"
    }
  }
}
