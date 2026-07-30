output "ec2_public_ip" {
  value       = module.ec2.public_ip
  description = "Your EC2 public IP use this for SSH and DNS"
}

output "ec2_public_dns" {
  value       = module.ec2.public_dns
  description = "Your EC2 public DNS hostname"
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
  description = "Your public subnet ID"
}

output "my_vpc_id" {
  value = module.vpc.my_vpc_id
  description = "Your VPC ID"
}
