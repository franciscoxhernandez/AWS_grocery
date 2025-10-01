resource "aws_db_subnet_group" "grocery_db_subnet_group" {
  name       = "grocery-db-subnet-group"
  subnet_ids = var.subnets
  tags       = { Name = "grocery-db-subnet-group" }
}

resource "aws_db_instance" "grocery_rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.grocery_db_subnet_group.name
  vpc_security_group_ids = [var.rds_security_group]
  skip_final_snapshot    = true
  publicly_accessible    = false
}