# Create dedicated VPC for the project
resource "aws_vpc" "dev_vpc" {
  cidr_block       = "10.0.0.0/16"
tags = {
    Name = "dev vpc"
  }
}

# Create public and private subnets
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
tags = {
    Name = "public subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = var.private_subnet_cidr_block
  availability_zone = "us-east-1b"
tags = {
    Name = "private subnet"
  }
}

# Since we have a public subnet, it is required to add an Internet Gateway for internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id
tags = {
    Name = "dev_vpc_igw"
  }
}

# In this step, a route table is created and associated with the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}
tags = {
    Name = "public route table"
  }
}

resource "aws_route_table_association" "dev_vpc_us-east-1a_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# According to this SG configuration, HTTP, SSH and PING traffic will be allowed to this instance from anywhere
resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh_sg"
  description = "Allow HTTP,SSH inbound connections"
  vpc_id = aws_vpc.dev_vpc.id
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
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 8
  to_port     = 0
  protocol    = "icmp"
  }
egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
tags = {
    Name = "Allow HTTP & SSH Traffic"
  }
}

# Import the Ubuntu_AMI module
module "ubuntu_ami" {
  source = "../modules/ec2_amis"
}

# Generate an RSA key pair for the EC2 server
resource "aws_key_pair" "EC2_server_key" {
  key_name   = "EC2_server_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

# Generate a private RSA key of 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the generated private key in a local file
resource "local_file" "TFEC2_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "EC2_server_key.pem"
  file_permission = "400"
}

# Define the WebServer EC2 instance
resource "aws_instance" "web_server" {
  ami           = module.ubuntu_ami.ami_id
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  subnet_id = aws_subnet.public_subnet.id
  key_name = aws_key_pair.EC2_server_key.key_name # Use the newly created RSA key for SSH connections
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  associate_public_ip_address = true
tags = {
    Name = "Web Server"
  }
}

# Next step to defien the Ansible server with user data script
resource "aws_instance" "asnible_server" {
  ami           = module.ubuntu_ami.ami_id
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  subnet_id = aws_subnet.public_subnet.id
  key_name = aws_key_pair.EC2_server_key.key_name # Use the newly created RSA key for SSH connections
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  associate_public_ip_address = true
  user_data              = var.user_data
tags = {
    Name = "Ansible Server"
  }
}