# Configure the AWS provider with the specified region
provider "aws" {
  region = "eu-west-1"
}

# Configure Aliases for other regions that S3 buckets will reside in
provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "eu-west-3"
  region = "eu-west-3"
}

provider "aws" {
  alias  = "eu-north-1"
  region = "eu-north-1"
}

provider "aws" {
  alias  = "eu-central-2"
  region = "eu-central-2"
}