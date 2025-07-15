import boto3
import os
import json
import urllib.request
import re
from datetime import datetime

SSM_PARAM = os.environ.get("SSM_PARAMETER_NAME", "/xcode/latest_version")
REGION = os.environ.get("AWS_REGION")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
SCHEDULE_EXPRESSION = os.environ.get("SCHEDULE_EXPRESSION", "rate(1 day)")
EMAIL_ADDRESS = os.environ.get("EMAIL_ADDRESS", "")

ssm = boto3.client("ssm", region_name=REGION)
sns = boto3.client("sns", region_name=REGION) if SNS_TOPIC_ARN else None

def get_latest_xcode_version():
    """Fetch the latest Xcode version from xcodereleases.com"""
    url = "https://xcodereleases.com/data.json"
    
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            data = json.loads(response.read().decode())
    except Exception as e:
        raise Exception(f"Failed to fetch Xcode releases data: {str(e)}")
    
    for release in data:
        try:
            download_url = release["links"]["download"]["url"]
            filename = os.path.basename(download_url)
            
            # Skip beta and RC versions
            if "beta" in filename.lower() or "rc" in filename.lower():
                continue
            
            # Extract version from filename
            match = re.search(r'Xcode_([a-zA-Z0-9._-]+)\.xip', filename)
            if match:
                version = match.group(1)
                release_date = release.get("date", {}).get("year", "Unknown")
                return {
                    "version": version,
                    "download_url": download_url,
                    "release_date": release_date,
                    "name": release.get("name", f"Xcode {version}")
                }
        except KeyError:
            continue
    
    raise Exception("No valid public Xcode release found.")

def get_ssm_version():
    """Get the current stored Xcode version from SSM Parameter Store"""
    try:
        param = ssm.get_parameter(Name=SSM_PARAM)
        current_value = param["Parameter"]["Value"]
        return None if current_value == 'initial' else current_value
    except ssm.exceptions.ParameterNotFound:
        return None

def update_ssm_version(version):
    """Update the stored Xcode version in SSM Parameter Store"""
    ssm.put_parameter(
        Name=SSM_PARAM,
        Value=version,
        Type="String",
        Overwrite=True,
        Description=f"Latest Xcode version - Updated on {datetime.utcnow().isoformat()}"
    )

def send_notification(subject, message):
    """Send notification via SNS"""
    if sns and SNS_TOPIC_ARN:
        try:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject=subject,
                Message=message
            )
            print(f"SNS notification sent: {subject}")
        except Exception as e:
            print(f"Failed to send SNS notification: {e}")

def send_setup_notification():
    """Send initial setup notification"""
    subject = "Xcode Version Checker - Setup Complete!"
    message = f"""Xcode Version Checker Setup Complete!

Your automated Xcode version checker has been successfully deployed and configured.

Configuration:
- Schedule: {SCHEDULE_EXPRESSION}
- Email: {EMAIL_ADDRESS}
- Region: {REGION}

The system will now automatically:
1. Check for new Xcode versions according to your schedule
2. Send you email notifications when updates are available
3. Track version history in AWS Systems Manager Parameter Store

Important: Please confirm your email subscription by clicking the link in the confirmation email from AWS SNS.

Your next version check will run according to the schedule, or you can trigger it manually from the AWS Lambda console.

Happy coding!

This notification was sent by your automated Xcode Version Checker."""
    
    send_notification(subject, message)

def lambda_handler(event, context):
    """Main Lambda handler function"""
    try:
        print(f"Starting Xcode version check at {datetime.utcnow().isoformat()}")
        print(f"Event received: {json.dumps(event)}")
        
        is_setup_trigger = event.get('setup_trigger', False)
        
        # Get latest Xcode version
        latest_info = get_latest_xcode_version()
        latest_version = latest_info["version"]
        current_version = get_ssm_version()
        
        print(f"Latest Xcode version: {latest_version}")
        print(f"Current stored version: {current_version}")
        
        # Handle first run (initial setup)
        if current_version is None:
            print("First run detected - sending setup notification")
            send_setup_notification()
            update_ssm_version(latest_version)
            return {
                "statusCode": 200,
                "status": "initial_setup",
                "initial_version": latest_version,
                "timestamp": datetime.utcnow().isoformat()
            }
        
        # Handle manual setup trigger
        if is_setup_trigger:
            print("Manual setup trigger - sending setup notification")
            send_setup_notification()
            return {
                "statusCode": 200,
                "status": "setup_notification_sent",
                "current_version": current_version,
                "timestamp": datetime.utcnow().isoformat()
            }
        
        # Check if update is needed
        if current_version == latest_version:
            print(f"No update required. Current version {current_version} is latest.")
            return {
                "statusCode": 200,
                "status": "no_update",
                "current_version": current_version,
                "timestamp": datetime.utcnow().isoformat()
            }
        
        # New version detected
        print(f"New version detected: {latest_version} (current: {current_version})")
        update_ssm_version(latest_version)
        
        # Send update notification
        subject = f"New Xcode Version Available: {latest_version}"
        message = f"""New Xcode version detected!

Previous Version: {current_version}
New Version: {latest_version}
Release Name: {latest_info.get('name', 'N/A')}
Download URL: {latest_info['download_url']}
Release Year: {latest_info['release_date']}

The SSM parameter '{SSM_PARAM}' has been updated automatically.

You can download the new version from the Apple Developer portal or use the direct link above.

Happy coding!

This notification was sent by your automated Xcode Version Checker."""
        
        send_notification(subject, message)
        
        return {
            "statusCode": 200,
            "status": "updated",
            "previous_version": current_version,
            "new_version": latest_version,
            "download_url": latest_info["download_url"],
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        error_msg = f"Error checking Xcode version: {str(e)}"
        print(error_msg)
        
        # Send error notification
        send_notification(
            "Xcode Version Check Failed", 
            f"{error_msg}\n\nTimestamp: {datetime.utcnow().isoformat()}\n\nPlease check the Lambda logs for more details."
        )
        
        return {
            "statusCode": 500,
            "status": "error",
            "message": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }