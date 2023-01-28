variable "efs_name" {
  type        = string
  description = "the name of the EFS"
}

variable "transition_to_ia" {
  type        = string
  description = "Indicates how long it takes to move files to IA storage class"
}

variable "performance_mode" {
  type        = string
  description = "The file system performance mode"
  default     = "generalPurpose"
}

variable "throughput_mode" {
  type        = string
  description = "Throughput mode for the file system"
  default     = "bursting"
}

variable "encrypted" {
  type        = bool
  description = "If true, the disk will be encrypted"
  default     = false
}

variable "subnets" {
  type        = map(string)
  description = "map of AZ with associated CIDR block"
}

variable "vpc_id" {
  default = "The VPC ids already provisioned for EFS"
}

variable "efs_access_point_name" {
  default = "EFS access point name"
}