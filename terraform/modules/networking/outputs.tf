output "subnet_a" {
  value = aws_subnet.grocery_subnet_a.id
}

output "subnet_b" {
  value = aws_subnet.grocery_subnet_b.id
}

output "ec2_sg_id" {
  value = aws_security_group.grocery_ec2_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.grocery_rds_sg.id
}