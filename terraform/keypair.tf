#keypair

resource "aws_key_pair" "my_key" {
  key_name = "my-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
