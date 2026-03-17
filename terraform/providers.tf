provider "aws" {
  region = "ap-south-1"
}


terraform {
  backend "s3" {
    bucket         = "harish-1685-new-bucket"
    key            = "Student-Teacher-Portal/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "my-dynamo-table"
    encrypt        = true
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}