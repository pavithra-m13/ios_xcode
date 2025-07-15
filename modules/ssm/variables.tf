# modules/ssm/variables.tf
variable "parameter_name" {
  description = "Name of the SSM parameter"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}