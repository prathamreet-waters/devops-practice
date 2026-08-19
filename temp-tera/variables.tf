variable "aws_region" {
  type    = string
  default = "ap-south-2"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "ChangeMeInProduction123!"
}
