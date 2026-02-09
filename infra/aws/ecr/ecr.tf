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
  region = "ap-south-2"
}

############################
# ECR Repositoriess
############################
resource "aws_ecr_repository" "cisco_frontend" {
  name = "cisco-frontend"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cisco-frontend"
  }
}

resource "aws_ecr_repository" "cisco_inventory" {
  name = "cisco-inventory"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cisco-inventory"
  }
}

resource "aws_ecr_repository" "cisco_orders" {
  name = "cisco-orders"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cisco-orders"
  }
}

############################
# Lifecycle Policy (Keep last 10 images)
############################
resource "aws_ecr_lifecycle_policy" "cisco_policy" {
  for_each = {
    frontend  = aws_ecr_repository.cisco_frontend.name
    inventory = aws_ecr_repository.cisco_inventory.name
    orders    = aws_ecr_repository.cisco_orders.name
  }

  repository = each.value

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
