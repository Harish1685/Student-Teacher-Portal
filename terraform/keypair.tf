#keypair

resource "aws_key_pair" "my_key" {
  key_name = "my-key"
  public_key = var.public_key
}
