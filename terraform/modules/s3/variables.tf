variable "environment" {
  type = string
}

variable "bucket_prefix" {
  type    = string
  default = "devops-practice"
}

variable "tags" {
  type    = map(string)
  default = {}
}
