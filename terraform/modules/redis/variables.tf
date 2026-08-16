variable "environment" {
  type = string
}

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "num_cache_clusters" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}
