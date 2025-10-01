variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}
variable "ec2_security_group" {}
variable "jwt_secret" { sensitive = true }
variable "db_user" {}
variable "db_password" { sensitive = true }
variable "db_name" {}
variable "rds_endpoint" {}