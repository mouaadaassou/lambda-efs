provider "aws" {
  region = "eu-central-1"
}

locals {
  lambda_function_name = "lambda_efs_writer"
}

module "vpc_module" {
  source              = "./vpc"
  vpc_name            = "vpc_efs_lambda"
  vpc_cidr_block      = "10.0.0.0/16"
  instance_tenancy    = "default"
  enable_dsn_hostname = true
  subnets_cidr = tomap({
    "eu-central-1a" : "10.0.0.0/21",
    "eu-central-1b" : "10.0.8.0/21",
    "eu-central-1c" : "10.0.16.0/21"
  })
}

module "efs_module" {
  source                = "./efs"
  efs_name              = "efs_lambda"
  transition_to_ia      = "AFTER_7_DAYS"
  performance_mode      = "generalPurpose"
  throughput_mode       = "bursting"
  encrypted             = false
  vpc_id                = module.vpc_module.vpc_id
  subnet_ids            = module.vpc_module.subnet_ids
  efs_access_point_name = "efs_access_point_for_lambda"

  subnets = tomap({
    "eu-central-1a" : "10.0.0.0/21",
    "eu-central-1b" : "10.0.8.0/21",
    "eu-central-1c" : "10.0.16.0/21"
  })
}

module "ec2_module" {
  source                          = "./ec2"
  efs_dns_name                    = module.efs_module.efs_dns_name
  ssh_key_name                    = "new-cloud-guru-labs"
  ec2_ami                         = "ami-0a261c0e5f51090b1"
  ec2_instance_type               = "t2.micro"
  ig_name                         = "ec2-ig"
  ec2_associate_public_ip_address = true
  subnet_ids                      = module.vpc_module.subnet_ids
  vpc_id                          = module.vpc_module.vpc_id
}

module "cloudwatch_module" {
  source               = "./cloudwatch"
  lambda_function_name = local.lambda_function_name
}

module "sqs_module" {
  source                           = "./sqs"
  queue_names                      = ["queue1", "queue2", "queue3", "queue4"]
  queue_delay_seconds              = 0
  queue_visibility_timeout_seconds = 300 # 5 minutest
}

module "lambda_module" {
  depends_on                                = [module.efs_module, module.cloudwatch_module]
  lambda_vpc_id                             = module.vpc_module.vpc_id
  cloudwatch_log_group_arn                  = module.cloudwatch_module.cloudwatch_log_group_arn
  lambda_maximum_batching_window_in_seconds = 10
  lambda_batch_size                         = 200
  lambda_package_type                       = "Zip"
  source                                    = "./lambda"
  subnet_ids                                = module.vpc_module.subnet_ids
  sqs_queues_arn                            = module.sqs_module.sqs_queues_arn
  lambda_runtime                            = "python3.9"
  lambda_handler                            = "lambda.lambda_handler"
  lambda_function_name                      = local.lambda_function_name
  lambda_role_name                          = "lambda_efs_writer_role"
  lambda_efs_access_point_arn               = module.efs_module.efs_access_point_arn
  lambda_function_assume_role_policy        = "lambda_function_assume_efs_write_role_policy"
  lambda_function_managed_policy_name       = "lambda_function_managed_efs_write_policy"
  lambda_function_managed_policy_statements = [
    {
      effect = "Allow",
      actions = tolist([
        "elasticfilesystem:ClientMount", "elasticfilesystem:ClientWrite", "elasticfilesystem:DescribeMountTargets"
      ]),
      resources = tolist(["*"])
    },
    {
      effect = "Allow"
      actions = tolist([
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances", "ec2:AttachNetworkInterface"
      ])
      resources = tolist(["*"])
    },
    {
      effect  = "Allow"
      actions = tolist(["logs:*"])
      resources = [
        module.cloudwatch_module.cloudwatch_log_group_arn,
        "${module.cloudwatch_module.cloudwatch_log_group_arn}/*"
      ]
    },
    {
      effect    = "Allow"
      actions   = tolist(["sqs:ReceiveMessage", "sqs:GetQueueAttributes", "sqs:DeleteMessage"])
      resources = module.sqs_module.sqs_queues_arn
    }
  ]
}