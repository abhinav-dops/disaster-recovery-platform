#!/bin/bash
set -e

yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker

docker pull ghcr.io/abhinav-dops/disaster-recovery-platform/dr-app:latest

docker run -d \
  --name dr-app \
  --restart unless-stopped \
  -p 80:80 \
  -e REGION_ROLE=${region_role} \
  -e S3_BUCKET=${s3_bucket} \
  -e AWS_REGION=${aws_region} \
  ghcr.io/abhinav-dops/disaster-recovery-platform/dr-app:latest