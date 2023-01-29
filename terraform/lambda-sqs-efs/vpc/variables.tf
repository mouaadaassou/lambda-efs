variable "vpc_name" {
  type        = string
  description = "The name of the VPC to provision"
}

variable "vpc_cidr_block" {
  default = "The CIDR block of the VPC to provision"
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "enable_dsn_hostname" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  default     = false
}

variable "subnets_cidr" {
  type        = map(string)
  description = "Map of subnet AZ associated with CIDR block"
}