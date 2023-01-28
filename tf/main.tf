provider "aws" {
  region = "eu-central-1"
}

module "efs" {
  source               = "./efs"
  vpc_cidr_block       = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  vpc_name             = "efs-vpc"

  ec2_key_name      = "new-cloud-guru-labs"
  ec2_ami           = "ami-0a261c0e5f51090b1"
  ec2_instance_type = "t2.micro"
  ec2_associate_public_ip_address = true

  encrypt_efs      = false
  throughput_mode  = "bursting"
  performance_mode = "generalPurpose"
  transition_to_ia = "AFTER_7_DAYS"
  efs_name         = "efs-demo"
  lambda-sg-id = module.lambda.lambda-sg-id

  enable_ig     = true
  subnet_per_az = tomap({
    "eu-central-1a" = "10.0.0.0/21"
    "eu-central-1b" = "10.0.8.0/21"
    "eu-central-1c" = "10.0.16.0/21"
  })
}

module "lambda" {
  source = "./lambda"
  vpc_cidr_block       = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  vpc_name             = "efs-vpc"
  peer_vpc_id = module.efs.efs_vpc_id
  efs_access_point_arn = module.efs.efs_access_point_arn
  subnet_cidr = tomap({
    "eu-central-1a": "192.168.0.0/21",
    "eu-central-1a": "192.168.8.0/21",
    "eu-central-1a": "192.168.16.0/21"
  })
}