# Updated variables.tf with new variables
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

# Apple credentials for Xcode downloads
variable "apple_id" {
  description = "Apple ID for downloading Xcode"
  type        = string
  sensitive   = true
  
  validation {
    condition     = can(regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", var.apple_id))
    error_message = "Must be a valid Apple ID (email address)."
  }
}

variable "app_password" {
  description = "App-specific password for Apple ID"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.app_password) >= 16
    error_message = "App-specific password must be at least 16 characters long."
  }
}

variable "public_key" {
  description = "Public key for SSH access to Mac instance"
  type        = string
}

# S3 configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for storing Xcode releases"
  type        = string
  default     = "xcode-releases-bucket"
}

# Mac instance configuration
variable "mac_instance_name" {
  description = "Name for the Mac instance"
  type        = string
  default     = "xcode-downloader"
}

variable "mac_instance_type" {
  description = "EC2 Mac instance type"
  type        = string
  default     = "mac1.metal"
  
  validation {
    condition = contains([
      "mac1.metal",
      "mac2.metal"
    ], var.mac_instance_type)
    error_message = "Mac instance type must be mac1.metal or mac2.metal."
  }
}

# Existing variables...
variable "schedule_expression" {
  description = "How often to check for Xcode updates (EventBridge schedule expression)"
  type        = string
  default     = "rate(1 day)"
}

variable "lambda_function_name" {
  description = "Name for the Lambda function"
  type        = string
  default     = "xcode-version-checker"
}

variable "sns_topic_name" {
  description = "Name for the SNS topic"
  type        = string
  default     = "xcode-version-updates"
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
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "xcode-version-checker"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}