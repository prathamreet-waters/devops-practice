variable "environment" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "ChangeMeInProduction123!"
}

variable "tags" {
  type    = map(string)
  default = {}
}
