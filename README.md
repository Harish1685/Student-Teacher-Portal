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
git clone https://github.com/Harish1685/Student-Teacher-Portal.git
cd Student-Teacher-Portal
```

## Step 3: Push Changes

Before setting up CI/CD pipelines, your project must be available in a GitHub repository.

### Initialize Git
```
git add .
git commit -m "initial commit"
```
### Create Repository on GitHub
- Go to GitHub
- Create a new repository
- Do NOT initialize with README (since you already have code)

### Connect Local Repo to GitHub
```
git remote add origin https://github.com/<your-username>/<repo-name>.git
git branch -M main
git push -u origin main
```
### Verify

Go to your GitHub repo and confirm:

- code is uploaded
- folders are visible

## Step 4: Set Up Terraform Remote Backend (S3 + DynamoDB)

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


## Step 5: Configure Terraform Backend & Create Infrastructure

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
### Generate SSH Key Pair

This key will be used by Terraform to allow SSH access to the EC2 instance.
Run:
```
ssh-keygen -t ed25519 -C "your-email@example.com"
```
Please Enter the default location

### Verify keys
```
ls ~/.ssh
```
You should see
```
id_ed25519
id_ed25519.pub
```
### Add SSH Public Key as GitHub Secret

Instead of storing the key locally, we pass it securely through GitHub Actions.

Add SSH Public Key as GitHub Secret

Get your public key
```
cat ~/.ssh/id_ed25519.pub
```
### Add it to GitHub Secrets

Go to your repository:

Settings → Secrets and variables → Actions → New repository secret

Add:
```
Name: PUBLIC_KEY
Value: <paste your public key>
```
<img width="1225" height="394" alt="image" src="https://github.com/user-attachments/assets/d8a58788-7001-4954-a82d-ec739ef047fe" />

### How this key is used

The public key is passed to Terraform through the CI/CD pipeline.
```
TF_VAR_public_key → var.public_key
```
This allows Terraform to use the key when creating the EC2 instance without storing it in code.

---

## Step 6: Run Terraform Using GitHub Actions

Instead of running Terraform manually, this project uses a pre-configured GitHub Actions workflow.

Required Secrets

Before running the pipeline, make sure these secrets are added in repository settings:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
PUBLIC_KEY
AWS_REGION
```
<img width="1196" height="492" alt="image" src="https://github.com/user-attachments/assets/5cbcf89a-97a3-414b-9603-e83803e577c8" />


### Run the Pipeline
1. Go to the Actions tab in your repository
2. Select Terraform-CICD
3. Click Run workflow
<img width="1841" height="852" alt="image" src="https://github.com/user-attachments/assets/97720fca-d23d-450a-b392-9726bdb8e815" />

### What this pipeline does
- Terraform Init → Connects to S3 backend
- Terraform Plan → Previews infrastructure
- Terraform Apply → Creates AWS resources

### Output

After successful execution:

- EC2 instance is created
- VPC and networking are configured
- SSH access is enabled using your key

### Note

Ensure your EC2 security group allows:

- Port 80 (HTTP)
- Port 22 (SSH)

Otherwise, the application will not be accessible from the browser.

---

## Step 7: Application CI/CD Pipeline (Build → Push → Deploy)

Now that the infrastructure is ready, we will automate the application deployment using GitHub Actions.

This pipeline will:

Build Docker images → Push to Docker Hub → Deploy to EC2

### Workflow Location

The deployment pipeline is already defined in:
```
.github/workflows/deploy.yml
```

### Required Secrets

Go to:

GitHub → Settings → Secrets → Actions

Add the following:
- DOCKERHUB_USER → your Docker Hub username
- DOCKERHUB_PASS → Docker Hub access token
- EC2_HOST → public IP from Terraform output
- EC2_USER → ubuntu
- EC2_SSH_KEY → private key
```
cat ~/.ssh/id_ed25519
```
Copy entire content and paste as secret

<img width="1196" height="881" alt="image" src="https://github.com/user-attachments/assets/6494b7cf-57e5-41d2-b876-57034aca0256" />

---

### Run the Deployment Pipeline
1.Go to Actions tab
2.Select Deploy workflow
3.Click Run workflow

<img width="1253" height="368" alt="image" src="https://github.com/user-attachments/assets/54209d40-33ce-4dc9-81d6-76f648f3ab4c" />

### What this pipeline does
1. Checkout code
2. Login to Docker Hub
3. Build frontend & backend images
4. Push images to Docker Hub
5. SSH into EC2
6. Pull latest images
7. Run docker compose

## Access the Application

Once deployment is complete, open:
```
http://<EC2_PUBLIC_IP>
```
Your application should be live

## Conclusion

In this project, we successfully built a complete end-to-end DevOps pipeline that automates both infrastructure provisioning and application deployment.

Using Terraform, Docker, and GitHub Actions, we transformed a local application into a fully deployed system on AWS EC2.

This setup enables:

- One-click infrastructure creation
- Automated application deployment
- Consistent and reproducible environments

This project demonstrates how modern DevOps practices can simplify and automate the entire deployment lifecycle.
