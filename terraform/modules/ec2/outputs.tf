output "public_ip" {
  value = aws_instance.grocery_ec2.public_ip
}

output "public_dns" {
  value = aws_instance.grocery_ec2.public_dns
}