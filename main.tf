# Primary Region (Mumbai)
module "vpc_primary" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  region_role        = "primary"
  vpc_cidr           = var.primary_vpc_cidr
  public_subnet_cidr = var.primary_public_subnet_cidr
  availability_zone  = "${var.primary_region}a"

  providers = {
    aws = aws.primary
  }
}

module "ec2_primary" {
  source = "./modules/ec2"

  project_name      = var.project_name
  environment       = var.environment
  region_role       = "primary"
  instance_type     = var.instance_type
  subnet_id         = module.vpc_primary.public_subnet_id
  security_group_id = module.vpc_primary.security_group_id
  key_name          = var.key_name
  s3_bucket         = module.s3.primary_bucket_name
  aws_region        = var.primary_region

  providers = {
    aws = aws.primary
  }
}

# Standby Region (Singapore)
module "vpc_standby" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  region_role        = "standby"
  vpc_cidr           = var.standby_vpc_cidr
  public_subnet_cidr = var.standby_public_subnet_cidr
  availability_zone  = "${var.standby_region}a"

  providers = {
    aws = aws.standby
  }
}

module "ec2_standby" {
  source = "./modules/ec2"

  project_name      = var.project_name
  environment       = var.environment
  region_role       = "standby"
  instance_type     = var.instance_type
  subnet_id         = module.vpc_standby.public_subnet_id
  security_group_id = module.vpc_standby.security_group_id
  key_name          = var.key_name
  s3_bucket         = module.s3.standby_bucket_name
  aws_region        = var.standby_region

  providers = {
    aws = aws.standby
  }
}

module "s3" {
  source = "./modules/s3"

  project_name  = var.project_name
  bucket_suffix = var.bucket_suffix

  providers = {
    aws.primary = aws.primary
    aws.standby = aws.standby
  }
}
