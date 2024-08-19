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

###########################################
### EC2 INSTANCE BLOCK with COUNT
###########################################
#resource "aws_instance" "my_first_server" {
#
#  count = 1 # create 2 similar EC2 instance
#
#  ami           = "ami-0d7a109bf30624c99"
#  instance_type = "t2.micro"
#    tags = {
#    Name = "strayan_test ${count.index}"
#  }
#
#}

###########################################
### AWS VPC resource
###########################################

resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.tag_name
  }
}

# 4. Create a subent

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = var.tag_name
  }
}

###########################################
### AWS Internet Gateway
###########################################
# 3. Create internet gateway

resource "aws_internet_gateway" "first-gateway" {
  vpc_id = aws_vpc.first-vpc.id

  tags = {
    Name = var.tag_name
  }
}

###########################################
### AWS Route Table
###########################################
resource "aws_route_table" "first-route-table" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.first-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.first-gateway.id
  }

  tags = {
    Name = var.tag_name
  }
}

# 5. Associate sutnet with Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.first-route-table.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" #any protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }    

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
    Name = "allow_web"
  }
}

# 7. Create a network interface with an ip in the subnet tha was created in step 4 

resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.subnet1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# 8. Assign an elastic IP to the netowrk interface creted in step 7

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.first-gateway ]
}

# 9. Create Ubuntu server and install/enable apache2

resource "aws_instance" "web" {
  ami           = "ami-04e5276ebb8451442"
  instance_type = "t2.micro"
  availability_zone = "us-west-2a"
  key_name = "strayan_test"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web_server_nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'
              EOF

  tags = {
    Name = var.tag_name
  }
}