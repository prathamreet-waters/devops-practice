variable "environment" {
  type = string
}

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "dbadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "ChangeMeInProduction123!"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
