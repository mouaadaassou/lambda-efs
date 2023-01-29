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

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.efs.id

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

  tags = {
    Name = var.efs_access_point_name
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_security_group.id]
}

resource "aws_security_group" "efs_security_group" {
  vpc_id = var.vpc_id

  tags = {
    Name = "efs_security_group"
  }
}

resource "aws_security_group_rule" "efs_ingress_security_group_rule" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_security_group.id
}

resource "aws_security_group_rule" "efs_egress_security_group_rule" {
  type              = "egress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_security_group.id
}