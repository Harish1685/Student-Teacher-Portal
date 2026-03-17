variable aws_ami_id {
    type = string
}

variable aws_instance_type {
    type = string
}

variable aws_key_name {
    type = string
}

variable aws_volume_size {
    type = number
}

variable "aws_volume_type" {
    type = string 
}

variable "aws_subnet_id" {
  type = string
}

variable "aws_vpc_id" {
  type = string
}