provider "aws" {
  region = "eu-central-1"
}

#####################
# VPC Configuration #
#####################
resource "aws_vpc" "efs-vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  # needed to mount EFS using DNS name
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "ec2-internet-gateway" {
  vpc_id = aws_vpc.efs-vpc.id
  tags   = {
    Name = "ec2-instance-ig"
  }
}

resource "aws_subnet" "efs-subnet" {
  for_each          = var.subnet_per_az
  vpc_id            = aws_vpc.efs-vpc.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = each.key
  }
}

#####################
# EFS Configuration #
#####################
resource "aws_efs_file_system" "cloud-guru-efs" {
  encrypted        = var.encrypt_efs
  throughput_mode  = var.throughput_mode
  performance_mode = var.performance_mode

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = {
    Name = var.efs_name
  }
}

# A mount target provides an IP address for an NFSv4 endpoint
# at which you can mount an Amazon EFS file system.
resource "aws_efs_mount_target" "efs-mount-target" {
  for_each        = aws_subnet.efs-subnet
  file_system_id  = aws_efs_file_system.cloud-guru-efs.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.ec2-security-group.id]
}

resource "aws_efs_access_point" "efs-access-point" {
  file_system_id = aws_efs_file_system.cloud-guru-efs.id

  root_directory {
    path = "/lambda"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = "0755"
    }
  }
  posix_user {
    # default ec2-user
    gid = 1001
    uid = 1001
  }
}

resource "null_resource" "configure_efs" {
  for_each   = aws_instance.cloud-guru-instance
  depends_on = [aws_efs_mount_target.efs-mount-target]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.cloud-guru-instance[each.key].public_ip
    private_key = file("/Users/moaad/.ssh/new-cloud-guru-labs.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install nfs-utils",
      "echo ${aws_efs_file_system.cloud-guru-efs.dns_name}",
      "ls -la",
      "pwd",
      "sudo mkdir -p efs",
      "ls -la",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.cloud-guru-efs.dns_name}:/ efs",
      "ls",
      "sudo chown -R ec2-user:ec2-user efs",
      "cd efs",
      "ls",
      "mkdir lambda",
      "cd lambda"
    ]
  }
}

#####################
# EC2 Configuration #
#####################
resource "aws_instance" "cloud-guru-instance" {
  for_each                    = aws_subnet.efs-subnet
  key_name                    = var.ec2_key_name
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = each.value.id
  associate_public_ip_address = var.ec2_associate_public_ip_address
  security_groups             = [aws_security_group.ec2-security-group.id]

  tags = {
    Name = each.value.availability_zone
  }
}

resource "aws_route_table" "ec2-instance-route-table" {
  vpc_id = aws_vpc.efs-vpc.id
  route {
    gateway_id = aws_internet_gateway.ec2-internet-gateway.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "ec2-instance-route-table-association" {
  for_each       = aws_subnet.efs-subnet
  route_table_id = aws_route_table.ec2-instance-route-table.id
  subnet_id      = each.value.id
}

resource "aws_security_group" "efs-security-group" {
  vpc_id = aws_vpc.efs-vpc.id

  ingress {
    from_port   = 2049
    protocol    = "TCP"
    to_port     = 2049
    security_groups = [var.lambda-sg-id]
  }

  egress {
    from_port   = 2049
    protocol    = "TCP"
    to_port     = 2049
    security_groups = [var.lambda-sg-id]
  }
}

resource "aws_security_group" "ec2-security-group" {
  vpc_id = aws_vpc.efs-vpc.id

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

  ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}