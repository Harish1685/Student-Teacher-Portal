
# vpc and security group

resource "aws_security_group" "my_security" {
  vpc_id = var.aws_vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "to open http access"
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "to open https access"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "to open ssh access"
  }

  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "to open http access for my app"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "to open access to everything"
  }


}
#instance

resource "aws_instance" "my_instance" {

  ami = var.aws_ami_id
  instance_type = var.aws_instance_type
  key_name = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.my_security.id]
  subnet_id = var.aws_subnet_id
  user_data = file("${path.module}/user_data.sh")
  
  root_block_device {
    volume_size = var.aws_volume_size
    volume_type = var.aws_volume_type
  }

  tags = {
    Name = "production"
    description = "my instance"
  }
}