
resource "aws_vpc" "vpc" {
  enable_dns_hostnames = var.enable_dsn_hostname
  cidr_block = var.vpc_cidr_block
  instance_tenancy = var.instance_tenancy

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "vpc_subnet" {
  for_each = var.subnets_cidr
  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value
  availability_zone = each.key

  tags = {
    Name = join("", ["subnet-", var.vpc_name, "-", each.key])
  }
}