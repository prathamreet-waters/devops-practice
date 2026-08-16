variable "environment" {
  type = string
}

variable "repository_name" {
  type    = string
  default = "devops-app"
}

variable "tags" {
  type    = map(string)
  default = {}
}
