# Root variables.tf
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "email_address" {
  description = "Email address to receive Xcode version update notifications"
  type        = string
  
  validation {
    condition     = can(regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", var.email_address))
    error_message = "Must be a valid email address."
  }
}

variable "schedule_expression" {
  description = "How often to check for Xcode updates (EventBridge schedule expression)"
  type        = string
  default     = "rate(1 day)"
  
  validation {
    condition = contains([
      "rate(1 hour)",
      "rate(6 hours)",
      "rate(12 hours)",
      "rate(1 day)",
      "rate(2 days)",
      "rate(1 week)"
    ], var.schedule_expression)
    error_message = "Schedule expression must be one of: rate(1 hour), rate(6 hours), rate(12 hours), rate(1 day), rate(2 days), rate(1 week)."
  }
}

variable "lambda_function_name" {
  description = "Name for the Lambda function"
  type        = string
  default     = "xcode-version-checker"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.lambda_function_name))
    error_message = "Lambda function name must contain only letters, numbers, hyphens, and underscores."
  }
}

variable "sns_topic_name" {
  description = "Name for the SNS topic"
  type        = string
  default     = "xcode-version-updates"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.sns_topic_name))
    error_message = "SNS topic name must contain only letters, numbers, hyphens, and underscores."
  }
}

variable "ssm_parameter_name" {
  description = "Name for the SSM parameter storing the current Xcode version"
  type        = string
  default     = "/xcode/latest_version"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
  
  validation {
    condition     = var.lambda_timeout >= 3 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 3 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
  
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 and 10240 MB."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch log retention period."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "xcode-version-checker"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}