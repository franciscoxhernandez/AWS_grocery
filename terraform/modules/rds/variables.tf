variable "db_name" {}
variable "db_user" {}
variable "db_password" { sensitive = true }
variable "subnets" { type = list(string) }
variable "rds_security_group" {}