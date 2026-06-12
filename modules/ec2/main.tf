data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.project_name}-${var.region_role}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "${var.project_name}-${var.region_role}-ec2-s3-policy"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::${var.s3_bucket}",
        "arn:aws:s3:::${var.s3_bucket}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "${var.project_name}-${var.region_role}-ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name
}


resource "aws_instance" "app" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name != "" ? var.key_name : null

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    region_role = var.region_role
    s3_bucket   = var.s3_bucket
    aws_region  = var.aws_region
  })

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  tags = {
    Name        = "${var.project_name}-${var.region_role}-app"
    Project     = var.project_name
    Environment = var.environment
    Region      = var.region_role
  }
}
