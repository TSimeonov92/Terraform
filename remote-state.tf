# NOTE: This config should be added to every directory which needs its own terraform state file.
# This config is used by Terraform to configure the remote s3 backend to store the .tfstate file

# Partial configuration of the remote state backend
# https://www.terraform.io/docs/backends/types/s3.html

#EXAMPLE

terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
