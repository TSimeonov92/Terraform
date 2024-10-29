# Manage multiple S3 buckets with one resource

resource "aws_s3_bucket" "veeam_backup_buckets_eu_west_1" {
  count         = length(var.s3_bucket_names) //count will be 3
  bucket        = "${var.s3_bucket_names[count.index]}-eu_west_1"
  acl           = "private"
  provider      = aws.eu-west-1
  force_destroy = true

  tags = {
    Customer = "${var.s3_bucket_names[count.index]}-eu_west_1"
  }
}

# Bucket for eu-west-1
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
## Bucket for eu-west-2
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