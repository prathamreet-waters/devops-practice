terraform {
  backend "s3" {
    bucket         = "prathamreet-waters-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "devops-practice-tfstate-locks"
    encrypt        = true
  }
}
