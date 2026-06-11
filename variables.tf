variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
  default     = "dr-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "primary_region" {
  description = "Primary AWS region (Mumbai)"
  type        = string
  default     = "ap-south-1"
}

variable "standby_region" {
  description = "Standby AWS region (Singapore)"
  type        = string
  default     = "ap-southeast-1"
}

variable "primary_vpc_cidr" {
  description = "CIDR block for primary VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "standby_vpc_cidr" {
  description = "CIDR block for standby VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "primary_public_subnet_cidr" {
  description = "CIDR block for primary public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "standby_public_subnet_cidr" {
  description = "CIDR block for standby public subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
  default     = ""
}

variable "bucket_suffix" {
  type    = string
  default = "abhinav-dr-2026"
}