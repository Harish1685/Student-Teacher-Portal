variable "public_key" {
  type = string
  description = "this is the public key"
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "who is allowed to SSH in. Set this to your own IP in terraform.tfvars"
}
