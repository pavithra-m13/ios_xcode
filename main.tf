# Root main.tf
provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# SSM Parameter for storing Xcode version
module "ssm" {
  source = "./modules/ssm"
  
  parameter_name = var.ssm_parameter_name
  tags = var.tags
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
  
  tags = var.tags
  
  depends_on = [module.sns, module.ssm]
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
