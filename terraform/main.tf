terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.region
}

module "networking" {
  source = "./modules/networking"
  region = var.region
}

module "rds" {
  source             = "./modules/rds"
  db_name            = var.db_name
  db_user            = var.db_user
  db_password        = var.db_password
  subnets            = [module.networking.subnet_a, module.networking.subnet_b]
  rds_security_group = module.networking.rds_sg_id
}

module "ec2" {
  source             = "./modules/ec2"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  jwt_secret         = var.jwt_secret
  db_user            = var.db_user
  db_password        = var.db_password
  db_name            = var.db_name
  rds_endpoint       = module.rds.db_endpoint
  subnet_id          = module.networking.subnet_a
  ec2_security_group = module.networking.ec2_sg_id
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "grocerymate-avatars-test"
  environment = "Dev"
}
