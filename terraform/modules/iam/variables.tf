variable "environment" {
  type = string
}

variable "create_oidc_role" {
  type    = bool
  default = false
}

variable "aws_account_id" {
  type    = string
  default = "123456789012"
}

variable "github_repo" {
  type    = string
  default = "prathamreet/devops-practice"
}

variable "tags" {
  type    = map(string)
  default = {}
}
