# modules/ssm/main.tf
resource "aws_ssm_parameter" "xcode_version" {
  name        = var.parameter_name
  type        = "String"
  value       = "initial"
  description = "Latest Xcode version tracked by the automated checker"
  
  tags = var.tags
}