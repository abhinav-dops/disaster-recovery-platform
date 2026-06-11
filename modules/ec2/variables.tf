variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region_role" {
  description = "Role of this region: primary or standby"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name (optional)"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID to use for the instance (leave empty to auto-lookup latest Amazon Linux 2023)"
  type        = string
  default     = ""
}
