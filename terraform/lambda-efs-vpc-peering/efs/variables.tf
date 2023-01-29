variable "vpc_cidr_block" {
  type        = string
  description = "the cidr block of the vpc to create"
}

variable "instance_tenancy" {
  type        = string
  description = "the type of the instance tenancy - default or dedicated"
  default     = "default"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "either to enable dns hostnames - required to mount efs"
  default     = false
}

variable "vpc_name" {
  type        = string
  description = "the name of the VPC to create"
}

variable "enable_ig" {
  type        = bool
  description = "whether to enable an IG or not for the VPC"
}

variable "subnet_per_az" {
  type        = map(string)
  description = "map to associate each subnet with an AZ"
}

variable "encrypt_efs" {
  type        = bool
  description = "whether to encrypt EFS or not"
  default     = false
}

variable "throughput_mode" {
  type        = string
  description = "the throughput mode of EFS - valid values => bursting, elastic, or provisioned"
  default     = "bursting"
}

variable "performance_mode" {
  type        = string
  description = "performance mode of the EFS - MaxIO or generalPurpose"
  default     = "generalPurpose"
}

variable "transition_to_ia" {
  type        = string
  description = "when to transit the file into the IA"
  default     = "AFTER_1_DAY"
}

variable "efs_name" {
  type        = string
  description = "the name of the EFS"
}

variable "ec2_key_name" {
  type        = string
  description = "the private key used to access the EC2 instance"
}

variable "ec2_ami" {
  type        = string
  description = "the EC2 ami used to launch the instance"
}

variable "ec2_instance_type" {
  type        = string
  description = "the instance type for EC2"
}

variable "ec2_associate_public_ip_address" {
  type        = bool
  description = "whether to associate a public ip address to the instance"
}

variable "lambda-sg-id" {
  type        = string
  description = "the efs access point arn"
}