# modules/sns/main.tf
resource "aws_sns_topic" "xcode_updates" {
  name         = var.topic_name
  display_name = "Xcode Version Updates"
  
  kms_master_key_id = "alias/aws/sns"
  
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.xcode_updates.arn
  protocol  = "email"
  endpoint  = var.email_address
}