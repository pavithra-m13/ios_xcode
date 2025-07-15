# modules/eventbridge/outputs.tf
output "rule_name" {
  description = "Name of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.xcode_version_check.name
}

output "rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.xcode_version_check.arn
}

output "rule_state" {
  description = "State of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.xcode_version_check.state
}