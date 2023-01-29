provider "aws" {
  region = "eu-central-1"
}

#####################
# VPC Configuration #
#####################
resource "aws_vpc" "lambda-vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  # needed to mount EFS using DNS name
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.vpc_name
  }
}

# Requester side of the connection
resource "aws_vpc_peering_connection" "lambda-vpc-peering-connection" {
  peer_vpc_id = var.peer_vpc_id
  vpc_id      = aws_vpc.lambda-vpc.id
  peer_region = "eu-central-1"
  auto_accept = false

  tags = {
    Name = "Lambda-VPC-Peering-Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "efs-vpc-peering-connection-accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.lambda-vpc-peering-connection.id
  auto_accept = true

  tags = {
    Name = "Lambda-VPC-Peering-Accepter"
  }
}

resource "aws_subnet" "lambda-subnet" {
  for_each = var.subnet_cidr
  vpc_id = aws_vpc.lambda-vpc.id
  cidr_block = each.value
  availability_zone = each.key

  tags = {
    Name = join("", ["Lambda-Subnet-", each.key])
  }
}

resource "aws_security_group" "lambda-sg" {
  vpc_id = aws_vpc.lambda-vpc.id

  ingress {
    from_port   = 2049
    protocol    = "TCP"
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 2049
    protocol    = "TCP"
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# Lambda Configuration #
########################
resource "aws_lambda_function" "lambda-efs-file-creator" {
  function_name = "efs_file_creator"
  role = aws_iam_role.lambda-efs-accessor.arn
  runtime = "python3.9"
  package_type = "Zip"
  handler = "lambda_handler"
  filename = data.archive_file.efs-file-creator.output_path
  source_code_hash = filebase64sha256(data.archive_file.efs-file-creator.source_file)

  file_system_config {
    arn              = var.efs_access_point_arn
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [for subnet in data.aws_subnet.subnet : subnet.id]
    security_group_ids = [aws_security_group.lambda-sg.id]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.lambda-vpc.id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}

data "archive_file" "efs-file-creator" {
  source_file = "${path.module}/lambda.py"
  output_path = "lambda.py.zip"
  type        = "zip"
}

resource "aws_iam_role" "lambda-efs-accessor" {
  name               = "lambda-efs-accessor"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.lambda-efs-accessor-policy.arn]
}

resource "aws_iam_policy" "lambda-efs-accessor-policy" {
  policy = data.aws_iam_policy_document.lambda-efs-accessor.json
}

data "aws_iam_policy_document" "lambda-efs-accessor" {


  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeMountTargets"
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }

  statement {
      effect = "Allow"
      actions = [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"]
      resources = ["*"]
    }
}

data "aws_iam_policy_document" "assume-role-policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}