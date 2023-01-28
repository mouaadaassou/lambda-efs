output "efs_vpc_id" {
  value = aws_vpc.efs-vpc.id
  description = "the id of the EFS vpc"
}

output "efs_access_point_arn" {
  value = aws_efs_access_point.efs-access-point.arn
  description = "the id of the EFS vpc"
}