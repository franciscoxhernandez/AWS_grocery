# 🏆 GroceryMate — AWS Deployed E-Commerce Platform  

[![Python](https://img.shields.io/badge/Language-Python%2C%20JavaScript-blue)](https://www.python.org/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform%20%F0%9F%92%A8-7B42BC)](https://www.terraform.io/)
[![Database](https://img.shields.io/badge/Database-PostgreSQL-336791)](https://www.postgresql.org/)
[![Cloud](https://img.shields.io/badge/Cloud-AWS-orange)](https://aws.amazon.com/)
[![Free](https://img.shields.io/badge/Free_for_Non_Commercial_Use-brightgreen)](#-license)

⭐ **Star this repository** if you find it helpful!  

---

## 📋 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Setup Instructions](#-setup-instructions)
- [Application Configuration](#-application-configuration)
- [Running the Application](#-running-the-application-)
- [S3 Bucket Integration](#-s3-bucket-integration)
- [Cleaning Up](#-cleaning-up)
- [License](#-license)

---

## 🚀 Overview

**GroceryMate** is a full-stack e-commerce platform deployed on **AWS** using **Terraform**.  
It includes:
- A **Flask backend** for business logic  
- A **React frontend** for the user interface  
- A **PostgreSQL RDS** database for persistent storage  
- An **EC2 instance** to host the app  
- An **S3 bucket** for user avatars  

This setup demonstrates a complete Infrastructure-as-Code (IaC) workflow for a cloud-native application.

---
### 🧭 AWS Architecture Diagram 

![AWS Architecture Diagram - AWS_grocery - AWS_grocery](https://github.com/user-attachments/assets/a8bd5414-a78a-4775-a8cd-2d17e501da2f)

---

## 🛒 Features

- **User Authentication** – Secure login & registration  
- **Product Catalog** – Filter, search, and view products  
- **Shopping Cart** – Add, update, and remove items  
- **Favorites Management** – Save preferred products  
- **Database Integration** – Hosted on AWS RDS (PostgreSQL)  
- **Cloud Storage** – Store user avatars in AWS S3  
- **IaC Deployment** – Fully reproducible via Terraform  

---

## 📸 Screenshots & Demo

![imagen](https://github.com/user-attachments/assets/ea039195-67a2-4bf2-9613-2ee1e666231a)
![imagen](https://github.com/user-attachments/assets/a87e5c50-5a9e-45b8-ad16-2dbff41acd00)
![imagen](https://github.com/user-attachments/assets/2772b85e-81f7-446a-9296-4fdc2b652cb7)

https://github.com/user-attachments/assets/d1c5c8e4-5b16-486a-b709-4cf6e6cce6bc

---

## 🧩 Prerequisites

Before starting, make sure you have the following installed:

- 🐍 **Python** (>=3.11)  
- 🐘 **PostgreSQL** (client + access to AWS RDS)  
- 🛠️ **Git** (for cloning this repository)  
- ☁️ **Terraform** (>=1.5.0)

---

## ⚙️ Setup Instructions

If you prefer a video walkthrough, watch this short tutorial: 

🎬 [Tutorial Video](https://aws-masterschool-podcast-cloud-basics-hernandez-short-version.s3.eu-central-1.amazonaws.com/GitHub_AWS_grocery_tutorial.mp4) → Video is hosted on a S3 🪣

Then follow the steps below to set up the project manually:

### 1️⃣ Clone the Repository
```
git clone --branch version2 https://github.com/franciscoxhernandez/AWS_grocery.git
cd AWS_grocery/terraform
````
### 2️⃣ Configure Terraform Variables
Create a file called `terraform.tfvars`: 
```
region        = "eu-central-1"
ami_id        = "ami-xxxxxxxx"     # Example: Amazon Linux 2023
instance_type = "t3.micro"
key_name      = "your-ec2-keypair"

db_name     = "grocerymate_db"
db_user     = "grocery_user"
db_password = "your-db-password"
jwt_secret  = "your-jwt-secret"
```
### 3️⃣ Deploy the Infrastructure
Run these commands in your terminal: 
```
terraform init
terraform plan
terraform apply
```
When prompted, type yes to confirm. 

After completion, you can verify resource creation on the **AWS Console**:
- **EC2** →  Running instance
- **RDS** →  PostgreSQL database
- **S3**  →  Avatar storage bucket 

### 4️⃣ Access Your Instance
Copy the **EC2 Public DNS** from the Terraform output and connect via SSH: 
```
ssh -i "your-key.pem" ec2-user@<EC2-Public-DNS>
```

### 5️⃣ Populate the Database
inside your EC2 terminal:
```
psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -f /home/ec2-user/AWS_grocery/backend/app/sqlite_dump_clean.sql
```
- Replace `<rds-endpoint>` with the value shown in your terraform output 
- Enter the password you define in  `terraform.tfvars`
- Once connected, the database will be populated with the initial data

## 🧠 Application Configuration

### 1️⃣ Access the Project Folder
```
cd /home/ec2-user/AWS_grocery/backend
```
### 2️⃣ Install Dependencies
```
pip3 install --upgrade pip
pip3 install -r requirements.txt
```
### 3️⃣ Generate a Secure JWT Key
```
python3 -c "import secrets; print(secrets.token_hex(32))"
```
Save this value for your `.env`file. 
### 4️⃣ Create and Edit `.env`
```
touch .env
nano .env
```
Insert the following:
```
JWT_SECRET_KEY=<your_generated_key>         # Replace with value from step 3 
POSTGRES_USER=grocery_user
POSTGRES_PASSWORD=your-db-password
POSTGRES_DB=grocerymate_db
POSTGRES_HOST=<rds-endpoint>                # Replace  with the value shown in your terraform output 
POSTGRES_URI=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}
```

## ▶️ Running the Application 
Start the Flask backend:
```
python3 run.py
```
Then open your browser and navigate to:
```
http://<EC2-Public-IP>:5006
```
Replace `<EC2-Public-IP>` with the value shown in your terraform output 

You can now explore the app, add products to your shopping cart, and confirm that data syncs with the RDS database.

## 🪣 S3 Bucket Integration

Your EC2 instance uses IAM roles to store user avatars in your **S3 bucket**.

### 1️⃣ Create a Folder for Avatars
inside the bucket `grocerymate-avatars`:
1. Click **Create folder** and name it **avatars**.
2. Upload a default image (e.g., `user_default.png` - from backend/avatar folder ) that the application can use for new users.

### 2️⃣ Attach IAM Role to EC2 for S3 Access
1. Open the **AWS IAM Console**.
2. Navigate to **Roles** → **Create Role**.
3. Select **AWS Service** → **EC2** → **Next**.
4. Attach the policy **AmazonS3FullAccess** (for dev use).
5. Name the role (e.g., `grocery-ec2-role`) → **Create Role**.
6. Attach the role to your EC2 instance:
   - Go to **EC2 Console** → **Instances**.
   - Select the instance → **Actions** → **Security** → **Modify IAM Role**.
   - Assign **`grocery-ec2-role`** → **Update IAM Role**.
### 3️⃣ Update Your `.env`
```
S3_BUCKET_NAME=grocerymate-avatars
S3_REGION=eu-central-1  # you difine the region where your App is being deploy 
USE_S3_STORAGE=true
```
### 4️⃣ Verify IAM Role Permissions on EC2
```
aws sts get-caller-identity  # Confirms the role is assumed
aws s3 ls s3://grocerymate-avatars/avatars/ # Confirms access to S3 bucket
```
### 5️⃣ Restart the App
```
sudo reboot
```
### 6️⃣ Verify the S3 Integration
After deploying, confirm that the application correctly interacts with S3:
1. Register a new user and upload an avatar.
2. Check the **S3 bucket** to see if the image is stored.

Avatars will now automatically upload to your S3 bucket 

## 🧹 Cleaning Up
When you’re done testing, remove all AWS resources:
```
terraform destroy
```
Confirm with yes when prompted.
You can verify deletion in your AWS Console — under EC2 and RDS, the instances will no longer appear.
## 📜 License

This project was developed as part of the [Masterschool](https://de.masterschool.com/en/) AI & Cloud Engineering program (2025),
with special thanks to [Alejandro Roman Ibanez](https://github.com/AlejandroRomanIbanez).

© 2025 Francisco Hernandez — MIT License.
