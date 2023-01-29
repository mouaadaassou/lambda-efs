variable "vpc_id" {
  type = string
  description = "The VPC id that EC2 instance will reside in"
}

variable "ssh_key_name" {
  type = string
  description = "the SSH key name"
}

variable "ec2_ami" {
  type = string
  description = "The AMI to use to instantiate EC2 instance"
}

variable "ec2_instance_type" {
  type = string
  description = "the SSH key name"
}

variable "ig_name" {
  type = string
  description = "Internet Gateway name"
}

variable "efs_dns_name" {
  type = string
  description = "DNS name of the EFS to mount to the EFS instance"
}

variable "subnet_ids" {
  description = "Subnet IDS"
}

variable "ec2_associate_public_ip_address" {
  type = bool
  description = "the SSH key name"
}