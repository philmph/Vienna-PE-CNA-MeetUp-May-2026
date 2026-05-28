terraform {
  required_version = ">= 1.15.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  # Step 1: Terraform — vars not supported in backend {}
  backend "local" {
    path = "states/${var.environment}/terraform.tfstate"
  }

  # Step 1 fix: comment out above, uncomment below, use -backend-config for the path
  # backend "local" {}
}
