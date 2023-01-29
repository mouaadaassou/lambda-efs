output "efs_dns_name" {
  value = aws_efs_file_system.efs.dns_name
}

output "efs_access_point_arn" {
  value = aws_efs_access_point.efs_access_point.arn
}