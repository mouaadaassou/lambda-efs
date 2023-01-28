provider "aws" {
  region = "eu-central-1"
}

module "vpc_module" {
  source              = "./vpc"
  vpc_name            = "vpc_efs_lambda"
  vpc_cidr_block      = "10.0.0.0/16"
  instance_tenancy    = "default"
  enable_dsn_hostname = true
  subnets_cidr        = tomap({
    "eu-central-1a" : "10.0.0.0/21",
    "eu-central-1b" : "10.0.8.0/21",
    "eu-central-1c" : "10.0.16.0/21"
  })
}

module "efs_module" {
  depends_on = [module.vpc_module.vpc_id]
  source           = "./efs"
  efs_name         = "efs_lambda"
  transition_to_ia = "AFTER_7_DAYS"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = false
  vpc_id           = module.vpc_module.vpc_id

  subnets = tomap({
    "eu-central-1a" : "10.0.0.0/21",
    "eu-central-1b" : "10.0.8.0/21",
    "eu-central-1c" : "10.0.16.0/21"
  })
}

module "ec2_module" {
  depends_on = [module.vpc_module.vpc_id]
  source                          = "./ec2"
  efs_dns_name                    = module.efs_module.efs_dns_name
  ssh_key_name                    = "new-cloud-guru-labs"
  ec2_ami                         = "ami-0a261c0e5f51090b1"
  ec2_instance_type               = "t2.micro"
  ig_name                         = "ec2-ig"
  ec2_associate_public_ip_address = true
  vpc_id                          = module.vpc_module.vpc_id
}