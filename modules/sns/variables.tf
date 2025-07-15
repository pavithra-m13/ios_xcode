# modules/sns/variables.tf
variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "email_address" {
  description = "Email address for notifications"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}