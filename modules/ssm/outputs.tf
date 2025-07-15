# modules/ssm/outputs.tf
output "parameter_name" {
  description = "Name of the SSM parameter"
  value       = aws_ssm_parameter.xcode_version.name
}

output "parameter_arn" {
  description = "ARN of the SSM parameter"
  value       = aws_ssm_parameter.xcode_version.arn
}

output "parameter_value" {
  description = "Value of the SSM parameter"
  value       = aws_ssm_parameter.xcode_version.value
}