variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "grocerymate_db"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "grocery_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret key for app authentication"
  type        = string
  sensitive   = true
}