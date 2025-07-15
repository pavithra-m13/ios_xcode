# modules/eventbridge/main.tf
resource "aws_cloudwatch_event_rule" "xcode_version_check" {
  name                = var.rule_name
  description         = "Scheduled check for new Xcode versions"
  schedule_expression = var.schedule_expression
  state               = "ENABLED"
  
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.xcode_version_check.name
  target_id = "XcodeVersionCheckerTarget"
  arn       = var.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.xcode_version_check.arn
}