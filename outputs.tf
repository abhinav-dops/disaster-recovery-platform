output "primary_vpc_id" {
  value = module.vpc_primary.vpc_id
}

output "primary_instance_public_ip" {
  value = module.ec2_primary.public_ip
}

output "standby_vpc_id" {
  value = module.vpc_standby.vpc_id
}

output "standby_instance_public_ip" {
  value = module.ec2_standby.public_ip
}

output "primary_bucket_name" {
  value = module.s3.primary_bucket_name
}

output "standby_bucket_name" {
  value = module.s3.standby_bucket_name
}