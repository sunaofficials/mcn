data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "mcnssna"          # your org
    workspaces = {
      name = "mcn-eks-network"       # EXACT network workspace name
    }
  }
}
