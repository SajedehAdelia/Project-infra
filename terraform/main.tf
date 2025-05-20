provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "api_server" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  tags = {
    Name = "API-Server"
  }

  provisioner "remote-exec" {
    inline = ["echo Hello, World!"]
  }
}
