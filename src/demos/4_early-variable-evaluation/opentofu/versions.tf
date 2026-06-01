terraform {
  required_version = ">= 1.8.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  backend "local" {
    path = "states/${var.environment}/terraform.tfstate"
  }
}
