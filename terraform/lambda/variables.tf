variable "lambda_function_name" {
  type        = string
  description = "Lambda function name"
}

variable "lambda_role_name" {
  type        = string
  description = "Role name associated with the Lambda function"
}

variable "lambda_function_assume_role_policy" {
  type        = string
  description = "Policy name associated with Role to assume by lambda function"
}

variable "lambda_function_managed_policy_name" {
  type        = string
  description = "Managed Policy name for lambda to access EFS"
}

variable "lambda_function_managed_policy_statements" {
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  description = "The Statements associated with the managed policy for lambda to access EFS"
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda Runtime"
}

variable "lambda_package_type" {
  type        = string
  description = "Lambda Package type"
}

variable "lambda_handler" {
  type        = string
  description = "Lambda handler name"
}

variable "lambda_efs_access_point_arn" {
  type        = string
  description = "EFS access point ARN to be used by lambda"
}

variable "lambda_vpc_id" {
  type        = string
  description = "Lambda VPC id"
}