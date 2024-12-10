# Manage multiple S3 buckets with a single resource
# Example using count

resource "aws_s3_bucket" "veeam_backup_buckets_eu_west_1" {
  count         = 0 #length(var.s3_bucket_names) //count will be 3
  bucket        = "${var.s3_bucket_names[count.index]}-eu-west-1"
  acl           = "private"
  provider      = aws.eu-west-1
  force_destroy = true

  tags = {
    Customer = "${var.s3_bucket_names[count.index]}-eu-west-1"
  }
}

# Managing multiple s3 buckets in multiple regions
# In this example we are using for_each

## Buckets for eu-west-1
#resource "aws_s3_bucket" "veeam_backup_buckets_eu_west_1" {
#  for_each      = toset(var.s3_bucket_names)
#  bucket        = "${each.key}-eu-west-1"
#  acl           = "private"
#  provider      = aws.eu-west-1
#  force_destroy = true
#
#  tags = {
#    Customer = each.key
#  }
#}
#
## Buckets for eu-west-2
#resource "aws_s3_bucket" "veeam_backup_buckets_eu_west_2" {
#  for_each      = toset(var.s3_bucket_names)
#  bucket        = "${each.key}-eu-west-2"
#  acl           = "private"
#  provider      = aws.eu-west-2
#  force_destroy = true
#
#  tags = {
#    Customer = each.key
#  }
#}