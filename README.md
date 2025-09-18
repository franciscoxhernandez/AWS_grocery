# GroceryMate on AWS 🚀

This project deploys the **GroceryMate e-commerce platform** on AWS using **Terraform**, **EC2**, and **RDS (PostgreSQL)**.  
It combines infrastructure-as-code with application deployment for a reproducible cloud setup.

---

## 📌 Features
- **Terraform-managed infrastructure**:
  - VPC, Subnets, Route Tables, Internet Gateway
  - EC2 Instance (Flask backend)
  - RDS PostgreSQL database
  - Security Groups with least-privilege rules
- **Automated Deployment**:
  - EC2 `user_data` installs Python, PostgreSQL client, and Git
  - App cloned from GitHub and launched automatically
- **RDS Integration**:
  - GroceryMate backend configured to connect to RDS
  - Database initialized manually from `sqlite_dump_clean.sql`
- **Accessible via Browser**:
  - Application runs on port **5006**
  - Reachable through EC2 Public DNS

---```bash

## 🛠️ Setup Instructions

### 1. Clone Repo
```bash
git clone https://github.com/franciscoxhernandez/AWS_grocery.git
cd AWS_grocery/terraform-grocery
````
### 2. Configure Variables - Edit terraform.tfvars with your values:
```bash
region        = "eu-central-1"
ami_id        = "ami-xxxxxx"     # Amazon Linux 2023 AMI
instance_type = "t2.micro"
key_name      = "your-ec2-keypair"

db_name     = "grocerymate_db"
db_user     = "grocery_user"
db_password = "supersecret"
jwt_secret  = "your-jwt-secret"
```
### 3. Deploy Infrastructure
```bash
terraform init
terraform apply
```
-Terraform will output:
	•	EC2 Public DNS
	•	RDS Endpoint 

 ### 4. Populate the Database
 - After Terraform finishes, you must populate the RDS PostgreSQL with the schema and initial data:
	1.	SSH into your EC2 instance:
```bash
   	ssh ec2-user@<ec2-public-dns>
```
  2.	Run the SQL import:
```bash
    	psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -f /home/ec2-user/AWS_grocery/backend/app/sqlite_dump_clean.sql
```
•	<rds-endpoint>: Copy from Terraform output rds_endpoint.
	    •	You will be prompted for the password (db_password from terraform.tfvars).

### 5. Verify data 
      ```bash
      psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -c "SELECT COUNT(*) FROM users;"
      psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -c "SELECT COUNT(*) FROM products;"
      ```

## Running the App
The app is started automatically on EC2 boot.
If you need to restart manually:
      ```bash
      ssh ec2-user@<ec2-public-dns>
      cd AWS_grocery/backend
      nohup python3 run.py 
      ```
Open in browser:
      ```bash
      http://<ec2-public-dns>:5006
      ```
