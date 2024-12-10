variable "customer_name" {
  type    = string
  default = "test-customer-1"
}

variable "s3_bucket_names" {
  type = list(string)
  default = [
    "customer1-prd-veeam-backup",
    "customer2-prd-veeam-backup",
    "customer3-prd-veeam-backup"
  ]
}

variable "regions" {
  type = list(string)
  default = [
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "eu-north-1",
    "eu-central-2"
  ]
}