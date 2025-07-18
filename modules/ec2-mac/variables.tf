variable "availability_zone" {
  description = "Availability zone to launch the Mac host and instance"
  type        = string
}

variable "instance_type" {
  description = "Mac instance type (e.g., mac1.metal or mac2.metal)"
  type        = string
}

variable "instance_name" {
  description = "Name of the Mac instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "mac1.metal"
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing Xcode releases"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for IAM permissions"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
