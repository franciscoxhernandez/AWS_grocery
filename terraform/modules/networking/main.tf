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

# EC2 Security Group
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

# RDS Security Group
resource "aws_security_group" "grocery_rds_sg" {
  name        = "grocery-rds-sg"
  description = "Allow PostgreSQL access from EC2"
  vpc_id      = aws_vpc.grocery_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.grocery_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "grocery-rds-sg" }
}