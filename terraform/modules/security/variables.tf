variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app_port" {
  type    = number
  default = 8000
}

variable "tags" {
  type    = map(string)
  default = {}
}
