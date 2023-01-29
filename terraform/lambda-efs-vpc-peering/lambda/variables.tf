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

variable "peer_vpc_id" {
  type        = string
  description = "the vpc id of the peer"
}

variable "subnet_cidr" {
  type        = map(string)
  description = "the cidr of the subnet"
}

variable "efs_access_point_arn" {
  type        = string
  description = "the efs access point arn"
}