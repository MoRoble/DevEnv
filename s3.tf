 resource "aws_kms_key" "s3bucketkey" {
   description              = "This will be the key used to encrypt buckets"        
   deletion_window_in_days  = 10
   enable_key_rotation      = true
 }
data "aws_caller_identity" "current" {}


 resource "aws_s3_bucket" "s3buckets" {
   count            = 1
   bucket           = var.bucketnames
   acl              = "private"
#    tags             = var.tags

   lifecycle_rule {
    enabled = true

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 60
      storage_class = "GLACIER"
    }
    
    expiration {
      days = 365
    }
   }
   
   server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.s3bucketkey.arn}"
        sse_algorithm     = "aws:kms"  
      }   
    } 
   } 
 }

 resource "aws_s3_bucket_public_access_block" "s3buckets" {
  count            = 1
  bucket           = aws_s3_bucket.s3buckets.*.id[count.index]
  block_public_acls   = true
  block_public_policy = true
 }
