# 🚀 DevOps Project: Full-Stack Application Deployment on AWS using Terraform, Docker & GitHub Actions

A hands-on DevOps project that automates infrastructure provisioning and application deployment using Terraform, Docker, and GitHub Actions  running on AWS EC2 with a fully containerized architecture.

## Introduction

Modern DevOps is not just about writing code ,it’s about automating everything from infrastructure to deployment.

In this project, I built a complete end-to-end pipeline that takes a full-stack application from local development to a live environment on AWS.

### Here’s what this setup includes:

- Terraform to provision AWS infrastructure (VPC, EC2, networking)
- Docker & Docker Compose to containerize and run the application
- GitHub Actions to automate build, push, and deployment
- Docker Hub to store application images
- AWS EC2 as the deployment server

### Application Stack

- React Frontend (served via Nginx)
- Node.js Backend
- MySQL Database

## 💻 System Requirements
- OS: ubuntu
- Git & github
- Docker & Docker Compose
- Terraform 
- AWS account

## Step 1: Set Up Your Environment 

Before building and deploying the application, ensure your system has the required tools installed

### Install Docker & Docker Compose 
```bash
sudo apt update
sudo apt install docker.io -y
```
Enable and start Docker:
```
sudo systemctl enable docker
sudo systemctl start docker
```
Add your user to Docker group and refresh:
```
sudo usermod -aG docker $USER && newgrp docker
```
Install docker compose:
```
sudo apt install docker-compose-plugin -y
```
Verify the installations:
```
docker --version
docker compose version
```
### Install Terraform
```
sudo apt install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y
```
Verify the Installation:
```
terraform -version
```

### ☁️ AWS Setup (IAM + CLI Configuration)
#### Create IAM User
- Go to AWS Console → IAM → Users → Create User
- Attach policy: AdministratorAccess
- Create user

<img width="1846" height="834" alt="image" src="https://github.com/user-attachments/assets/543f943b-90c0-4e12-a43d-7837c6984c28" />

<img width="1362" height="795" alt="image" src="https://github.com/user-attachments/assets/aa88ca16-0224-4a8b-a8b0-27969e32faa2" />

<img width="1692" height="570" alt="image" src="https://github.com/user-attachments/assets/ee06a07d-2849-4fca-b1e5-6a6019fba08a" />

#### Creating Accesskeys:
- Go to Security Credentials
- Click Create Access Key
- Select CLI use case
Save:
- Access Key ID
- Secret Access Key

⚠️ These will not be shown again.

### Configure AWS CLI

Install AWS CLI:
```
sudo apt install awscli -y
```
Configure:
```
aws configure
```

Enter:
```
AWS Access Key ID
AWS Secret Access Key
Region : ap-south-1
Output format: json
```
Verify:
```
aws sts get-caller-identity
```
If this works → AWS CLI is configured correctly ✅


---


## Step 2: Clone the Project Repository

Now that the environment is ready, the next step is to clone the project repository

```
https://github.com/Harish1685/Student-Teacher-Portal.git
cd Student-Teacher-Portal
```

---


## Step 3: Set Up Terraform Remote Backend (S3 + DynamoDB)

Before running Terraform, we need to configure a remote backend to store state and manage locking.
### Create S3 Bucket (State Storage)
```
aws s3api create-bucket \
  --bucket my-s3-new-buckett12 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```
### Create DynamoDB Table (State Locking)
```
aws dynamodb create-table \
  --table-name my-dynamo-table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```
#### ⚠️ Important

These must be created before running terraform init

---


## Step 4: Configure Terraform Backend & Create Infrastructure

Now that the remote backend (S3 + DynamoDB) is ready, we can initialize Terraform and provision the infrastructure

---

### Navigate to Terraform Directory
```
cd terraform
```
### Configure Backend

Open your backend configuration (providers.tf) and update it:
```
terraform {
  backend "s3" {
    bucket         = "my-s3-new-buckett12"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "my-dynamo-table"
  }
}
```
