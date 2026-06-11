terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary region: Mumbai
provider "aws" {
  alias  = "primary"
  region = "ap-south-1"
}

# Standby region: Singapore
provider "aws" {
  alias  = "standby"
  region = "ap-southeast-1"
}
