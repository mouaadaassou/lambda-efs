resource "aws_efs_file_system" "efs" {
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  encrypted        = var.encrypted

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = {
    Name = var.efs_name
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each = toset(data.aws_subnets.subnets.ids)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = each.key
  security_groups = [aws_security_group.efs_security_group.id]
}

resource "aws_security_group" "efs_security_group" {
  vpc_id = var.vpc_id

  tags = {
    Name = "efs_security_group"
  }
}

resource "aws_security_group_rule" "efs_ingress_security_group_rule" {
  type = "ingress"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_security_group.id
}

resource "aws_security_group_rule" "efs_egress_security_group_rule" {
  type = "egress"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_security_group.id
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}