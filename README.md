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

### The application itself consists of:

- React frontend (served via Nginx)
- Node.js backend
- MySQL database

## 💻 System Requirements
- OS: ubuntu
- Git & github
- Docker & Docker Compose
- Terraform 
- AWS account

## Step 1: Set Up Your Environment 

Before we start building and deploying the application, we need to prepare our system with the required tools and accounts.

This project uses Docker, Terraform, AWS, and GitHub  so make sure everything is properly installed and configured.

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
### setup AWS account and configure AWS CLI using IAM
Go to aws console , make an account and login into the console and go to IAM -> Users -> Create user to create an user

Enter the username and click next:
<img width="1846" height="834" alt="image" src="https://github.com/user-attachments/assets/543f943b-90c0-4e12-a43d-7837c6984c28" />
After that  select "Attach policies directly" , search for administrator access, select it and click next:
<img width="1362" height="795" alt="image" src="https://github.com/user-attachments/assets/aa88ca16-0224-4a8b-a8b0-27969e32faa2" />
On clicking create User, the user would be created and it would be available on IAM -> Users
<img width="1692" height="570" alt="image" src="https://github.com/user-attachments/assets/ee06a07d-2849-4fca-b1e5-6a6019fba08a" />


