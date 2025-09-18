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

# -------------------------
# Networking
# -------------------------
resource "aws_vpc" "grocery_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "grocery-vpc" }
}

resource "aws_internet_gateway" "grocery_igw" {
  vpc_id = aws_vpc.grocery_vpc.id
  tags   = { Name = "grocery-igw" }
}

resource "aws_subnet" "grocery_subnet_a" {
  vpc_id                  = aws_vpc.grocery_vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "grocery-subnet-a" }
}

resource "aws_subnet" "grocery_subnet_b" {
  vpc_id                  = aws_vpc.grocery_vpc.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "grocery-subnet-b" }
}

resource "aws_route_table" "grocery_rt" {
  vpc_id = aws_vpc.grocery_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.grocery_igw.id
  }

  tags = { Name = "grocery-rt" }
}

resource "aws_route_table_association" "grocery_rta_a" {
  subnet_id      = aws_subnet.grocery_subnet_a.id
  route_table_id = aws_route_table.grocery_rt.id
}

resource "aws_route_table_association" "grocery_rta_b" {
  subnet_id      = aws_subnet.grocery_subnet_b.id
  route_table_id = aws_route_table.grocery_rt.id
}

# Security Group for EC2
resource "aws_security_group" "grocery_ec2_sg" {
  name        = "grocery-ec2-sg"
  description = "Allow SSH and Flask app traffic"
  vpc_id      = aws_vpc.grocery_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5006
    to_port     = 5006
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "grocery-ec2-sg" }
}

# Security Group for RDS
resource "aws_security_group" "grocery_rds_sg" {
  name        = "grocery-rds-sg"
  description = "Allow PostgreSQL access from EC2"
  vpc_id      = aws_vpc.grocery_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.grocery_ec2_sg.id] # ✅ allow EC2 SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "grocery-rds-sg" }
}
# -------------------------
# RDS Subnet Group
# -------------------------
resource "aws_db_subnet_group" "grocery_db_subnet_group" {
  name       = "grocery-db-subnet-group"
  subnet_ids = [aws_subnet.grocery_subnet_a.id, aws_subnet.grocery_subnet_b.id]
  tags       = { Name = "grocery-db-subnet-group" }
}

# -------------------------
# RDS PostgreSQL
# -------------------------
resource "aws_db_instance" "grocery_rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.grocery_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.grocery_rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

# -------------------------
# EC2 Instance with User Data
# -------------------------
resource "aws_instance" "grocery_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.grocery_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.grocery_ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update packages
              yum update -y
              yum install -y python3 python3-pip git postgresql15

              # Clone GroceryMate repo
              cd /home/ec2-user
              git clone https://github.com/franciscoxhernandez/AWS_grocery.git
              cd AWS_grocery/backend

              # Install Python requirements
              pip3 install --upgrade pip
              pip3 install -r requirements.txt

              # Set env vars
              echo "export JWT_SECRET_KEY=${var.jwt_secret}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_USER=${var.db_user}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_PASSWORD=${var.db_password}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_DB=${var.db_name}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_HOST=${aws_db_instance.grocery_rds.address}" >> /home/ec2-user/.bashrc
              source /home/ec2-user/.bashrc

              # Run Flask app in background
              nohup python3 run.py --port=5006 > /home/ec2-user/app.log 2>&1 &
              EOF

  tags = {
    Name = "GroceryApp-EC2"
  }
}

# -------------------------
# Outputs
# -------------------------
output "ec2_public_ip" {
  value = aws_instance.grocery_ec2.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.grocery_ec2.public_dns
}

output "rds_endpoint" {
  value = aws_db_instance.grocery_rds.address
}