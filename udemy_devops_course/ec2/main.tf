terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}


# Deploy new EC2 instance
resource "aws_instance" "my_first_server" {

  count = 1 # create 2 similar EC2 instance

  ami           = "ami-0440fa9465661a496" # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  key_name = aws_key_pair.test-key-pair.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    tags = {
    Name = "strayan_test ${count.index}"
  }

}

# Create key-pair for ssh login
resource "aws_key_pair" "test-key-pair" {
  key_name   = "test-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

# Create rsa key
# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create local pem file for the key
resource "local_file" "test-key-pair" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "test-key-pair"
}

# Create Security Group to allow ssh
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }    

  tags = {
    Name = "allow_ssh"
  }
}