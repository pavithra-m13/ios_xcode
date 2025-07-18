# modules/lambda/variables.tf - Updated
variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
}

variable "ssm_parameter_name" {
  description = "Name of the SSM parameter storing the current Xcode version"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule expression for version checks"
  type        = string
}

variable "email_address" {
  description = "Email address to receive notifications"
  type        = string
}

# New variables for S3 and Mac instance
variable "s3_bucket_name" {
  description = "S3 bucket name for storing Xcode releases"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for IAM permissions"
  type        = string
}

variable "mac_instance_id" {
  description = "EC2 Mac instance ID for running download commands"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}