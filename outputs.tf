# Root outputs.tf
output "lambda_function_name" {
  description = "Name of the created Lambda function"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = module.sns.topic_arn
}

output "ssm_parameter_name" {
  description = "Name of the SSM parameter storing the current Xcode version"
  value       = module.ssm.parameter_name
}

output "schedule_expression" {
  description = "EventBridge schedule expression for version checks"
  value       = var.schedule_expression
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule"
  value       = module.eventbridge.rule_name
}

output "manual_test_command" {
  description = "AWS CLI command to manually trigger setup notification"
  value       = "aws lambda invoke --function-name ${module.lambda.function_name} --region ${data.aws_region.current.name} --payload '{\"setup_trigger\":true}' response.json"
}

output "logs_command" {
  description = "AWS CLI command to view Lambda logs"
  value       = "aws logs tail /aws/lambda/${module.lambda.function_name} --region ${data.aws_region.current.name} --follow"
}

output "email_confirmation_note" {
  description = "Important reminder about email confirmation"
  value       = "IMPORTANT: Check your email (including spam folder) for AWS SNS subscription confirmation and click the confirmation link to receive notifications."
}

output "setup_note" {
  description = "Important setup information"
  value       = "The setup notification will be sent automatically on the first scheduled run, or you can trigger it manually using the manual_test_command output."
}