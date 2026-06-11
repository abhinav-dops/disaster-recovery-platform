output "primary_bucket_name" {
  value = aws_s3_bucket.primary.id
}

output "standby_bucket_name" {
  value = aws_s3_bucket.standby.id
}

output "primary_bucket_arn" {
  value = aws_s3_bucket.primary.arn
}

output "standby_bucket_arn" {
  value = aws_s3_bucket.standby.arn
}