# Xcode Version Checker - Terraform

This Terraform configuration deploys an automated Xcode version checker that monitors for new Xcode releases and sends email notifications when updates are available.

## Features

- **Automated Monitoring**: Scheduled checks for new Xcode versions using EventBridge
- **Email Notifications**: SNS-based email alerts for new releases
- **Version Tracking**: Stores current version in AWS Systems Manager Parameter Store
- **Modular Architecture**: Well-structured Terraform modules for easy maintenance
- **Configurable Scheduling**: Flexible check intervals (hourly to weekly)
- **Error Handling**: Comprehensive error handling with failure notifications

## Architecture

The solution consists of:

- **Lambda Function**: Python-based function that checks for new Xcode versions
- **SNS Topic**: Handles email notifications
- **SSM Parameter**: Stores the current tracked Xcode version
- **EventBridge Rule**: Schedules automated checks
- **CloudWatch Logs**: Stores Lambda execution logs
- **IAM Roles**: Secure permissions for Lambda execution

## Project Structure

```
xcode-version-checker/
├── main.tf                     # Root module
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── versions.tf                 # Provider requirements
├── terraform.tfvars.example    # Example configuration
├── README.md                   # This file
└── modules/
    ├── lambda/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── lambda_function.py
    ├── sns/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ssm/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── eventbridge/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

1. **AWS Account**: Active AWS account with appropriate permissions
2. **Terraform**: Version 1.0 or later installed
3. **AWS CLI**: Configured with appropriate credentials
4. **Email Address**: Valid email for receiving notifications

## Setup Instructions

### 1. Clone or Download the Configuration

Create a new directory and save all the Terraform files in the structure shown above.

### 2. Configure Variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
# Required
email_address = "your-email@example.com"

# Optional (defaults provided)
aws_region = "us-east-1"
schedule_expression = "rate(1 day)"
lambda_function_name = "xcode-version-checker"
sns_topic_name = "xcode-version-updates"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan the Deployment

```bash
terraform plan
```

Review the planned changes to ensure everything looks correct.

### 5. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 6. Confirm Email Subscription

After deployment:

1. Check your email (including spam folder)
2. Look for an AWS SNS subscription confirmation email
3. Click the confirmation link to start receiving notifications

### 7. Test the Setup (Optional)

You can manually trigger the setup notification using the AWS CLI command from the Terraform output:

```bash
aws lambda invoke --function-name xcode-version-checker --region us-east-1 --payload '{"setup_trigger":true}' response.json
```

## Configuration Options

### Schedule Expressions

Available scheduling options:

- `rate(1 hour)` - Check every hour
- `rate(6 hours)` - Check every 6 hours  
- `rate(12 hours)` - Check every 12 hours
- `rate(1 day)` - Check daily (default)
- `rate(2 days)` - Check every 2 days
- `rate(1 week)` - Check weekly

### Lambda Configuration

Customize Lambda performance:

```hcl
lambda_timeout = 60        # Timeout in seconds (3-900)
lambda_memory_size = 128   # Memory in MB (128-10240)
log_retention_days = 14    # CloudWatch log retention
```

### Tags

Add custom tags for resource organization:

```hcl
tags = {
  Project     = "xcode-version-checker"
  Environment = "production"
  Owner       = "your-name"
  Team        = "ios-dev"
}
```

## Monitoring and Troubleshooting

### View Logs

Monitor Lambda execution logs:

```bash
aws logs tail /aws/lambda/xcode-version-checker --region us-east-1 --follow
```

### Manual Execution

Test the Lambda function manually:

```bash
aws lambda invoke --function-name xcode-version-checker --region us-east-1 response.json
cat response.json
```

### Common Issues

1. **No Email Notifications**: Ensure email subscription is confirmed
2. **Lambda Timeouts**: Increase timeout value if needed
3. **Permission Errors**: Verify IAM roles have necessary permissions
4. **Network Issues**: Check VPC settings if Lambda is in a VPC

## Outputs

After deployment, Terraform provides useful outputs:

- **lambda_function_name**: Name of the created Lambda function
- **sns_topic_arn**: ARN of the SNS topic
- **manual_test_command**: Command to manually trigger the function
- **logs_command**: Command to view Lambda logs

## Cost Considerations

This solution is designed to be cost-effective:

- **Lambda**: Pay per execution (typically < $1/month)
- **SNS**: Pay per notification (first 1,000 free)
- **SSM**: Parameter Store is free for standard parameters
- **EventBridge**: First 1 million events free per month
- **CloudWatch Logs**: Pay for log storage and retention

## Security Features

- **IAM Roles**: Least privilege access principles
- **KMS Encryption**: SNS topic encrypted with AWS managed keys
- **VPC Support**: Can be deployed in VPC if needed
- **Resource Tagging**: Consistent tagging for compliance

## Customization

The modular structure allows easy customization:

1. **Add New Notification Channels**: Extend SNS module for Slack, Teams, etc.
2. **Custom Version Sources**: Modify Lambda to check different sources
3. **Additional Metadata**: Store more version information in SSM
4. **Multi-Region**: Deploy across multiple regions

## Cleanup

To remove all resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Support

For issues or questions:

1. Check the CloudWatch logs for error details
2. Verify all prerequisites are met
3. Ensure AWS credentials have necessary permissions
4. Review the Terraform plan output for any issues

## License

This project is provided as-is for educational and practical use. Modify as needed for your specific requirements.