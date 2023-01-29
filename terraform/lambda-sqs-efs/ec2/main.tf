resource "aws_instance" "ec2_instance" {
  count                       = length(var.subnet_ids)
  subnet_id                   = var.subnet_ids[count.index]
  key_name                    = var.ssh_key_name
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = var.ec2_associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]

  tags = {
    Name = join("", ["ec2-", var.subnet_ids[count.index]])
  }
}

resource "aws_internet_gateway" "ec2_internet_gateway" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.ig_name
  }
}

resource "aws_route_table" "ec2_instance_route_table" {
  vpc_id = var.vpc_id
  route {
    gateway_id = aws_internet_gateway.ec2_internet_gateway.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "ec2_instance_route_table_association" {
  count          = length(var.subnet_ids)
  route_table_id = aws_route_table.ec2_instance_route_table.id
  subnet_id      = var.subnet_ids[count.index]
}

resource "aws_security_group" "ec2_security_group" {
  vpc_id = var.vpc_id

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

resource "null_resource" "configure_efs" {
  count = length(aws_instance.ec2_instance)

  triggers = {
    cluster_instance_ids = join(",", aws_instance.ec2_instance.*.id)
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.ec2_instance[count.index].public_ip
    private_key = file("/Users/moaad/.ssh/new-cloud-guru-labs.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install nfs-utils",
      "echo ${var.efs_dns_name}",
      "ls -la",
      "pwd",
      "mkdir -p efs",
      "ls -la",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${var.efs_dns_name}:/ efs",
      "ls",
      "sudo chown -R ec2-user:ec2-user efs",
      "cd efs",
      "ls",
      "mkdir lambda",
      "cd lambda"
    ]
  }
}
