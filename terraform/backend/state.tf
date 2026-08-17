terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "devops-practice-tfstate-global"
    key            = "terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "devops-practice-tfstate-locks"
    encrypt        = true
  }
}
