terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/Users/saeid_000/.aws/credentials"
}


# variable "subnet_prefix" {
#   # type        = string
#   # default     = ""
#   description = "cider block for the subnet"
# }

 
# Create a VPC
resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test-vpc"
  }
}



# VPC Flow Log 
resource "aws_flow_log" "test-flowlog" {
  iam_role_arn    = aws_iam_role.test-flowlog.arn
  log_destination = aws_cloudwatch_log_group.test-flowlog.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.test-vpc.id
}

resource "aws_cloudwatch_log_group" "test-flowlog" {
  name = "test-flowlog"
}

resource "aws_iam_role" "test-flowlog" {
  name = "test-flowlog"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test-flowlog" {
  name = "test-flowlog"
  role = aws_iam_role.test-flowlog.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_flow_log" "test-flowlog-01" {
  log_destination      = aws_s3_bucket.test-flowlog-01.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id          = aws_vpc.test-vpc.id
}

resource "aws_s3_bucket" "test-flowlog-01" {
  bucket = "test-flowlog-01"
}