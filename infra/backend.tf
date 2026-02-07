terraform {
    
  backend "s3" {
  bucket = "mcn-bucket"
  key    = "eks/dev/terraform.tfstate"
  region = "ap-south-2"
  dynamodb_table = "mcn-terraform"
  encrypt = true

}

required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}