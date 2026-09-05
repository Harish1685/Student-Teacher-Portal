# 🚀 DevOps Project: Full-Stack Application Deployment on AWS using Terraform, Docker & GitHub Actions

A hands-on DevOps project that provisions AWS infrastructure with Terraform and automates application deployment using Docker and GitHub Actions, running on AWS EC2 with a fully containerized architecture.

## Introduction

Modern DevOps is not just about writing code ,it’s about automating everything from infrastructure to deployment.

In this project, I built a complete end-to-end pipeline that takes a full-stack application from local development to a live environment on AWS.

### Here’s what this setup includes:

- Terraform to provision AWS infrastructure (VPC, EC2, networking) — run manually, see Step 6
- Docker & Docker Compose to containerize and run the application
- GitHub Actions to automate build, push, and deployment
- Docker Hub to store application images
- AWS EC2 as the deployment server

### Where the line is drawn

**Infrastructure is created by hand. Only the application deploys automatically.**

The infrastructure is created once and rarely changes, so I run Terraform myself and read the plan before applying. The application code changes all the time, so that part is automated.

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

## Step 4: Create the State Backend (Terraform Bootstrap)

Terraform stores its state — a record of everything it has created — in a remote S3 bucket and locks it with a DynamoDB table. But that bucket has to exist **before** the main Terraform config can even run `terraform init`, because the main config stores its own state *inside* that bucket. A chicken-and-egg problem.

The fix is a small, separate Terraform config in `terraform/bootstrap/`. Its only job is to create the S3 bucket + DynamoDB table once. That keeps the whole setup as code — no manual console clicks or one-off CLI commands for state.

### Run the bootstrap
```
cd terraform/bootstrap
terraform init
terraform plan    # you should see the S3 bucket + DynamoDB table being ADDED
terraform apply
```

### Why the backend can't live in the main config

The main config stores its state in the S3 bucket, so it can't create that bucket itself — the bucket must exist first. `bootstrap` exists only to break that deadlock: it runs once with its own local state, then the main config takes over and stores its state remotely in the bucket.

### How the Terraform is organized

```
terraform/
├── bootstrap/          ← one-time: creates the state backend (S3 + DynamoDB)
├── modules/            ← reusable building blocks: vpc, ec2, s3, dynamoDB
├── main.tf             ← the real infrastructure (uses the modules)
├── providers.tf        ← AWS provider + remote backend config
├── keypair.tf          ← EC2 key pair created from your public key
├── variables.tf        ← inputs (public key, SSH allowed IPs)
├── outputs.tf          ← useful values (EC2 IP, VPC ID)
└── terraform.tfvars.example   ← template for your real values (copy to terraform.tfvars)


---


## Step 5: Configure Terraform Backend & SSH Key

Now that the remote backend (S3 + DynamoDB) is ready, we can point Terraform at it and prepare the SSH key it needs

---

### Navigate to Terraform Directory
```
cd terraform
```
### Confirm the Backend Config

The S3 backend is already wired up in `providers.tf`. Just check the names match what bootstrap created in Step 4:
```
terraform {
  backend "s3" {
    bucket         = "harish-1685-new-bucket"
    key            = "Student-Teacher-Portal/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "my-dynamo-table"
    encrypt        = true
  }
}
```
### Generate SSH Key Pair

This one key does two jobs: it gives **you** SSH access to the EC2 instance, and GitHub Actions uses it to deploy the app.
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
### Pass the Public Key to Terraform

Terraform needs your **public** key to create the EC2 key pair. Since we run Terraform from our own machine, it goes in a `terraform.tfvars` file — which is gitignored, so it never reaches GitHub:
```
cd terraform
cp terraform.tfvars.example terraform.tfvars
```
Print your public key:
```
cat ~/.ssh/id_ed25519.pub
```
Paste it into `terraform.tfvars` so the file reads:
```
public_key = "ssh-ed25519 AAAAC3Nza... your-email@example.com"
```

> 🔑 **Public vs private key:** the **public** key (`.pub`) goes to Terraform here. The **private** key goes into GitHub Secrets in Step 7 so Actions can SSH in. Never mix these up — the private key is the one that must stay secret.

---

## Step 6: Create the Infrastructure (Manual Terraform)

Terraform runs **from your own machine**, not from a pipeline.

> **Why not automate this?** I tried putting Terraform in a pipeline first, but a pipeline runs `apply` on every push with nobody checking the plan — and a wrong plan can delete the server or the database. Since the infrastructure is created only once, running it myself and reading the plan first is safer and simpler. The application deploy is the part that runs often, so that is the part I automated.

### Initialize
```
cd terraform
terraform init
```
This connects to the S3 backend and downloads the AWS provider.

### Review the plan
```
terraform plan
```
Actually read it before continuing. You should see resources to **add**, and nothing to **destroy**.

### Apply
```
terraform apply
```
Type `yes` to confirm. Takes about 2 minutes.

### Get your server details
```
terraform output
```
```
ec2_public_dns   = "ec2-13-234-56-78.ap-south-1.compute.amazonaws.com"
ec2_public_ip    = "13.234.56.78"
my_vpc_id        = "vpc-0abc123..."
public_subnet_id = "subnet-0def456..."
```
Copy `ec2_public_ip` — this becomes your `EC2_HOST` secret in Step 7.

### Wait for the server to finish setting itself up

The instance boots with a `user_data` script that installs Docker and Docker Compose. Give it a minute, then SSH in:
```
ssh -i ~/.ssh/id_ed25519 ubuntu@<EC2_PUBLIC_IP>
```
Once you're in, confirm it finished:
```
cat ~/setup.log        # should print: Setup complete
docker --version
docker compose version
```
If `setup.log` doesn't exist yet, `user_data` is still running — wait 30 seconds and check again.

> ⚠️ **Deploying before `user_data` finishes is the most common cause of a failed first deploy.** The SSH step succeeds, then `docker compose` isn't installed yet.

### What Terraform created

- A VPC with a public subnet, internet gateway and route table
- An EC2 instance (Ubuntu 22.04) with Docker + Docker Compose preinstalled
- A security group allowing port 80 (HTTP), 443 (HTTPS) and 22 (SSH)

Port 3500 is not opened in the security group, so the backend cannot be reached from the internet. Nginx talks to it inside the Docker network instead.

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
- EC2_HOST → public IP from `terraform output`
- EC2_USER → ubuntu
- EC2_SSH_KEY → **private** key
```
cat ~/.ssh/id_ed25519
```
Copy entire content and paste as secret

> ℹ️ No AWS keys are needed here. This pipeline only builds images and connects to a server that already exists.

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
5. Copy `docker-compose.yml` to the server
6. SSH into EC2 and pull the new images
7. Start the containers with `docker compose up -d`
8. Check that the app actually responds

Two things I learned while building this:

**Images are tagged with the commit SHA instead of `latest`.** That way I always know exactly which build is running on the server.

**The image names are saved in a `~/app/.env` file on the server.** Docker Compose reads `.env` automatically. I first used `export` inside the SSH step, which worked for that one step, but the variables vanished when the session closed — so later, when I SSHed in myself to run `docker compose logs`, Compose warned that the image name was not set.

## Access the Application

Once deployment is complete, open:
```
http://<EC2_PUBLIC_IP>
```
Your application should be live

---

## Step 8: Verifying and Debugging a Deployment

When something looks wrong, SSH in and work through these in order.

```
ssh -i ~/.ssh/id_ed25519 ubuntu@<EC2_PUBLIC_IP>
cd ~/app
```

### Are all three containers up and healthy?
```
docker compose ps
```
All three should say `Up`, and `backend` / `database` should say `(healthy)`.

### Check the logs of whatever isn't
```
docker compose logs backend
docker compose logs database
docker compose logs frontend
```

### Test each layer from the inside out

This is the useful trick — test the backend directly first, then through nginx. Whichever one fails tells you where the problem is.
```
curl localhost:3500/health          # is the backend alive?
curl localhost:3500/health/db       # can it reach MySQL?
curl localhost/                     # is nginx serving the React app?
curl localhost/api/student          # does the proxy reach the backend?
```

### Common failures

| What you see | What it means |
|---|---|
| `docker: command not found` during deploy | `user_data` hadn't finished. Wait a minute, re-run the workflow |
| backend restarting in a loop | MySQL isn't reachable. Check `docker compose logs database` |
| Site loads, lists are empty, browser console shows 502 | nginx can't reach the backend. Check `docker compose ps backend` |
| `manifest unknown` on pull | Image tag doesn't exist on Docker Hub. Check the build step actually pushed |
| `variable is not set` warning from compose | `~/app/.env` is missing. Re-run the deploy workflow |
| Nothing running after a reboot | Should be fixed by `restart: unless-stopped`. Check `systemctl is-enabled docker` |

### Restarting by hand

Because the settings are in `~/app/.env`, you can run Compose directly on the server:
```
cd ~/app
docker compose restart backend     # restart one service
docker compose up -d               # bring everything back up
docker compose logs -f backend     # follow logs live
```

---

## Step 9: Tearing It All Down

An EC2 instance left running costs money. When you're done:

### Destroy the infrastructure
```
cd terraform
terraform destroy
```
Type `yes`. This removes the EC2 instance, VPC, subnet, gateway and security group.

### Remove the backend resources (optional)

The state backend is removed by the same `bootstrap` config that created it — run this **after** the `terraform destroy` above:
```
cd terraform/bootstrap
terraform destroy
```

If it refuses to delete the S3 bucket because it still holds the state file from the main config, empty it first, then destroy again:
```
aws s3 rm s3://harish-1685-new-bucket --recursive
cd terraform/bootstrap
terraform destroy
```

### Verify nothing is left running
```
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].[InstanceId,InstanceType]" \
  --region ap-south-1
```

---

## Conclusion

In this project, we built a complete deployment setup for a full-stack application on AWS.

Using Terraform, Docker, and GitHub Actions, we transformed a local application into a fully deployed system on AWS EC2.

This setup enables:

- Reproducible infrastructure defined as code
- Automated application deployment on every push to `main`
- Deploys that fail loudly instead of silently going green
- Containers that survive crashes and reboots on their own

This project demonstrates how modern DevOps practices can simplify and automate the deployment lifecycle — and, just as importantly, where drawing the line at automation is the right engineering call.
