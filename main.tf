# Root main.tf - Updated
provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get default VPC and subnet
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# SSM Parameters
module "ssm" {
  source = "./modules/ssm"
  
  parameter_name = var.ssm_parameter_name
  tags = var.tags
}

# Additional SSM parameters for Apple credentials
resource "aws_ssm_parameter" "apple_id" {
  name  = "/xcode/apple_id"
  type  = "SecureString"
  value = var.apple_id
  description = "Apple ID for Xcode downloads"
  tags = var.tags
}

resource "aws_ssm_parameter" "app_password" {
  name  = "/xcode/app_password"
  type  = "SecureString"
  value = var.app_password
  description = "App-specific password for Apple ID"
  tags = var.tags
}

# S3 bucket for storing Xcode releases
module "s3" {
  source = "./modules/s3"
  
  bucket_name = var.s3_bucket_name
  tags = var.tags
}

# EC2 Mac instance for downloading Xcode
module "ec2_mac" {
  source = "./modules/ec2-mac"
  
  instance_name   = var.mac_instance_name
  instance_type   = var.mac_instance_type
  public_key      = var.public_key
  vpc_id          = data.aws_vpc.default.id
  subnet_id       = data.aws_subnets.default.ids[0]
  s3_bucket_name  = module.s3.bucket_name
  s3_bucket_arn   = module.s3.bucket_arn
  tags            = var.tags
}

# SNS Topic and Subscription
module "sns" {
  source = "./modules/sns"
  
  topic_name    = var.sns_topic_name
  email_address = var.email_address
  tags = var.tags
}

# Lambda Function
module "lambda" {
  source = "./modules/lambda"
  
  function_name        = var.lambda_function_name
  sns_topic_arn        = module.sns.topic_arn
  ssm_parameter_name   = var.ssm_parameter_name
  schedule_expression  = var.schedule_expression
  email_address        = var.email_address
  lambda_timeout       = var.lambda_timeout
  lambda_memory_size   = var.lambda_memory_size
  log_retention_days   = var.log_retention_days
  s3_bucket_name       = module.s3.bucket_name
  s3_bucket_arn        = module.s3.bucket_arn
  mac_instance_id      = module.ec2_mac.instance_id
  tags = var.tags
  
  depends_on = [module.sns, module.ssm, module.s3, module.ec2_mac]
}

# EventBridge Rule for scheduling
module "eventbridge" {
  source = "./modules/eventbridge"
  
  rule_name           = "${var.lambda_function_name}-schedule"
  schedule_expression = var.schedule_expression
  lambda_function_arn = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
  
  tags = var.tags
  
  depends_on = [module.lambda]
}