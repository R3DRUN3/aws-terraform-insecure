
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# COMPLIANT TEST FIXTURE.
# Intended for static c7n-left scanning, not deployment.

resource "aws_s3_bucket" "compliant" {
  bucket = "conform-compliant-test-bucket-001"
}

resource "aws_s3_bucket_public_access_block" "compliant" {
  bucket = aws_s3_bucket.compliant.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ebs_volume" "compliant" {
  availability_zone = "eu-west-1a"
  size              = 8
  encrypted         = true

  tags = {
    Name = "conform-compliant-test-volume"
  }
}

resource "aws_security_group" "compliant" {
  name        = "conform-compliant-test-sg"
  description = "Compliant test security group"

  # No unrestricted SSH or RDP ingress rules.
  # Add narrowly scoped ingress rules only if required.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudtrail" "compliant" {
  name                          = "conform-compliant-test-trail"
  s3_bucket_name                = aws_s3_bucket.compliant.id
  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_db_instance" "compliant" {
  identifier              = "conform-compliant-test-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "testadmin"
  password                = var.db_password
  skip_final_snapshot     = false
  storage_encrypted       = true
  publicly_accessible     = false
  backup_retention_period = 7
}

variable "db_password" {
  description = "Dummy value for static scanning; never use a real credential."
  type        = string
  sensitive   = true
  default     = "Dummy-Only-Password-123!"
}
