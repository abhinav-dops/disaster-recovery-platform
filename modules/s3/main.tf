terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.primary, aws.standby]
    }
  }
}

resource "aws_s3_bucket" "primary" {
  provider = aws.primary
  bucket   = "${var.project_name}-primary-${var.bucket_suffix}"

  tags = {
    Name    = "${var.project_name}-primary-bucket"
    Project = var.project_name
  }
}

resource "aws_s3_bucket" "standby" {
  provider = aws.standby
  bucket   = "${var.project_name}-standby-${var.bucket_suffix}"

  tags = {
    Name    = "${var.project_name}-standby-bucket"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "standby" {
  provider = aws.standby
  bucket   = aws_s3_bucket.standby.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication" {
  provider = aws.primary
  name     = "${var.project_name}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "replication" {
  provider = aws.primary
  name     = "${var.project_name}-s3-replication-policy"
  role     = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = [aws_s3_bucket.primary.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = ["${aws_s3_bucket.primary.arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = ["${aws_s3_bucket.standby.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "primary_to_standby" {
  provider   = aws.primary
  depends_on = [aws_s3_bucket_versioning.primary, aws_s3_bucket_versioning.standby]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.primary.id

  rule {
    id     = "replicate-to-standby"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.standby.arn
      storage_class = "STANDARD"
    }
  }
}