resource "aws_iam_role" "ec2_role" {
  name = "grocery-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "grocery-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "grocery_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.ec2_security_group]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              set -e
              yum update -y
              yum install -y python3 python3-pip git postgresql15

              # Clone repo
              cd /home/ec2-user
              git clone https://github.com/franciscoxhernandez/AWS_grocery.git
              chown -R ec2-user:ec2-user AWS_grocery

              cd AWS_grocery/backend
              pip3 install --upgrade pip
              pip3 install -r requirements.txt

              # Set env vars (write to bashrc so they persist)
              echo "export JWT_SECRET_KEY=${var.jwt_secret}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_USER=${var.db_user}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_PASSWORD=${var.db_password}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_DB=${var.db_name}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_HOST=${var.rds_endpoint}" >> /home/ec2-user/.bashrc
              echo "export POSTGRES_URI=postgresql://${var.db_user}:${var.db_password}@${var.rds_endpoint}:5432/${var.db_name}" >> /home/ec2-user/.bashrc

              # Fix frontend permissions
              chown -R ec2-user:ec2-user /home/ec2-user/AWS_grocery/frontend
              chmod -R 755 /home/ec2-user/AWS_grocery/frontend

              # Start the app (background)
              nohup python3 run.py --port=5006 > /home/ec2-user/app.log 2>&1 &
              EOF

  tags = { Name = "GroceryApp-EC2" }
}