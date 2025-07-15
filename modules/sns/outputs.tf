# modules/sns/outputs.tf
output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.xcode_updates.arn
}

output "topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.xcode_updates.name
}

output "subscription_arn" {
  description = "ARN of the email subscription"
  value       = aws_sns_topic_subscription.email_notification.arn
}