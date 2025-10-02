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

---

## 🛠️ Setup Instructions

### 1. Clone Repo
```bash
git clone https://github.com/franciscoxhernandez/AWS_grocery.git
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
```
terraform init
terraform apply
```
#### Terraform will output:
•	EC2 Public DNS
•	RDS Endpoint 
### 4. Populate the Database
After Terraform finishes, you must populate the RDS PostgreSQL with the schema and initial data:
1. SSH into your EC2 instance:
```
ssh ec2-user@<ec2-public-dns>
```
2. Run the SQL import:
```
psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -f /home/ec2-user/AWS_grocery/backend/app/sqlite_dump_clean.sql
```
•	<rds-endpoint>: Copy from Terraform output rds_endpoint. You will be prompted for the password (db_password from terraform.tfvars).

### 5. Verify data 
```
psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -c "SELECT COUNT(*) FROM users;"
psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -c "SELECT COUNT(*) FROM products;"
```
## Running the App
The app starts automatically on EC2 boot.
If you need to restart manually:
```
ssh ec2-user@<ec2-public-dns>
cd AWS_grocery/backend
nohup python3 run.py
```
Open in browser:
```
http://<ec2-public-dns>:5006
```

---

# 🌩️ S3 Bucket Integration

To enable S3 storage for user avatars and static files:

### **Step 1: Create an S3 bucket in your region (e.g., `grocerymate-avatars`). Add this code to the main.tf or create a new file (e.g., `s3.tf`)** 

```
resource "aws_s3_bucket" "avatars" {
  bucket = "grocerymate-avatars"

  tags = {
    Name        = "grocerymate-avatars-francisco"
    Environment = "Dev"
  }
}
```
### **Step 2: Apply the configuration** 
```
terraform init
terraform plan
terraform apply -auto-approve 
````
### **Step 3: Attach an IAM Role to EC2 for S3 Access**

Instead of storing credentials in `.env`, the **EC2 instance should assume an IAM role** with permissions to access S3.

1. Open the **AWS IAM Console**.
2. Navigate to **Roles** → **Create Role**.
3. Select **AWS Service** → **EC2** → **Next**.
4. Attach the policy **AmazonS3FullAccess** (for development).
5. Name the role (e.g., `grocery-ec2-role`) → **Create Role**.
6. Attach the role to your EC2 instance:
   - Go to **EC2 Console** → **Instances**.
   - Select the instance → **Actions** → **Security** → **Modify IAM Role**.
   - Assign **`grocery-ec2-role`** → **Update IAM Role**.

### Step 4: Update your `.env` file with the following variables:

```
# PostgreSQL
POSTGRES_USER=grocery_user
POSTGRES_PASSWORD=your-db-password
POSTGRES_DB=grocerymate_db
POSTGRES_HOST=<rds-endpoint>    # or localhost if using local Postgres
POSTGRES_URI=postgresql://grocery_user:your-db-password@<rds-endpoint>:5432/grocerymate_db

# S3
S3_BUCKET_NAME=grocerymate-avatars
S3_REGION=eu-central-1
USE_S3_STORAGE=true

# Optional if not using IAM role
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
```
### Step 5: If your EC2 instance has an IAM role with S3 permissions, you don’t need to set AWS keys in `.env`.
### Step 6: Restart the application (either host or Docker). Uploaded avatars will now be stored in your S3 bucket. 
Since the application is running inside Docker, we must pass the environment variables dynamically:


```
docker run --network host \
  -e S3_BUCKET_NAME=grocerymate-avatars \
  -e S3_REGION=eu-central-1 \
  -e USE_S3_STORAGE=true \
  -e POSTGRES_USER=grocery_user \
  -e POSTGRES_PASSWORD=grocery_test \
  -e POSTGRES_DB=grocerymate_db \
  -e POSTGRES_HOST=<your-rds-endpoint> \
  -e POSTGRES_URI=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB} \
  -p 5000:5000 grocerymate
```
---
This repository and documentation were developed during the [Masterschool](https://de.masterschool.com/en/) program (2025), with special thanks to [Alejandro Roman Ibanez](https://github.com/AlejandroRomanIbanez).
