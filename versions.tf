# versions.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# Optional: Configure remote backend for state management
# terraform {
#   backend "s3" {
#     bucket = "your-terraform-state-bucket"
#     key    = "xcode-version-checker/terraform.tfstate"
#     region = "us-east-1"
#   }
# }