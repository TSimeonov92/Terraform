# Create new SG with ingress rules for SSH, HTTP, Grafana and Prometheus 
resource "aws_security_group" "grafana_sg" {
  name        = "Grafana_SG"
  description = "Allow HTTP/S, SSH, Grafana & Prometheus inbound connections"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow HTTP/S, SSH, Grafana & Prometheus Traffic"
  }
}

# Generate an RSA key pair for the Grafana server
resource "aws_key_pair" "Grafana_server_key" {
  key_name   = "Grafana_server_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

# Generate a private RSA key of 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the generated private key in a local file
resource "local_file" "Grafana_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "Grafana_server_key.pem"
  file_permission = "400"
  directory_permission = "400"
}

# Import the Ubuntu_AMI module
module "ubuntu_ami" {
  source = "../modules/ec2_amis"
}

# Create an AWS EC2 instance for Grafana server
resource "aws_instance" "Grafana_server" {
  ami                    = module.ubuntu_ami.ami_id # Using the custom module for ubuntu AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]
  user_data              = var.user_data
  key_name               = aws_key_pair.Grafana_server_key.key_name

  tags = {
    Name = "Grafana EC2 server"
  }
}