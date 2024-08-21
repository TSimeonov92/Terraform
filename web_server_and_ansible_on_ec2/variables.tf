variable "region" {
  description = "default region"
  type = string
  default = "us-east-1"
}

variable "availability_zone" {
  description = "default availability zone"
  type = string
  default = "us-east-1a"
  
}

variable "public_subnet_cidr_block" {
   description = "public_subnet_cidr_block"
   type        = string
   default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
   description = "private_subnet_cidr_block"
   type        = string
   default     = "10.0.2.0/24"
}

variable "instance_type" {
   description = "instance_type"
   type        = string
   default     = "t2.micro"
}

# Define user data script for the ansible server
variable "user_data" {
    default = <<-EOF
               #!/bin/bash
               # Install ansible package
               sudo apt update
               sudo apt install software-properties-common
               sudo add-apt-repository --yes --update ppa:ansible/ansible
               sudo apt install ansible
               EOF
}