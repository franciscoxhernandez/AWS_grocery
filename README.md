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
cd AWS_grocery/terraform-grocery


