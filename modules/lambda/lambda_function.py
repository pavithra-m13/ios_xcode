import boto3
import os
import json
import urllib.request
import re
from datetime import datetime

# Environment variables
SSM_PARAM = os.environ.get("SSM_PARAMETER_NAME", "/xcode/latest_version")
REGION = os.environ.get("AWS_REGION")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
S3_BUCKET = os.environ.get("S3_BUCKET_NAME")
MAC_INSTANCE_ID = os.environ.get("MAC_INSTANCE_ID")
SCHEDULE_EXPRESSION = os.environ.get("SCHEDULE_EXPRESSION", "rate(1 day)")
EMAIL_ADDRESS = os.environ.get("EMAIL_ADDRESS", "")

# AWS clients
ssm = boto3.client("ssm", region_name=REGION)
sns = boto3.client("sns", region_name=REGION) if SNS_TOPIC_ARN else None
s3 = boto3.client("s3", region_name=REGION)

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
                return {
                    "version": version,
                    "download_url": download_url,
                    "release_date": release.get("date", {}).get("year", "Unknown"),
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

def check_s3_file_exists(version):
    """Check if Xcode version already exists in S3"""
    try:
        s3.head_object(Bucket=S3_BUCKET, Key=f"xcode-{version}.xip")
        return True
    except:
        return False

def trigger_xcode_download(download_url, version):
    """Trigger Xcode download on Mac instance via SSM Run Command"""
    if not MAC_INSTANCE_ID:
        print("No Mac instance configured for download")
        return None
    
    try:
        command = f'/usr/local/bin/download_xcode.sh "{download_url}" "{version}"'
        
        response = ssm.send_command(
            InstanceIds=[MAC_INSTANCE_ID],
            DocumentName="AWS-RunShellScript",
            Parameters={
                'commands': [command]
            },
            Comment=f"Download Xcode version {version}"
        )
        
        command_id = response['Command']['CommandId']
        print(f"Started download command: {command_id}")
        return command_id
        
    except Exception as e:
        print(f"Failed to trigger download: {str(e)}")
        return None

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

def lambda_handler(event, context):
    """Main Lambda handler function"""
    try:
        print(f"Starting Xcode version check at {datetime.utcnow().isoformat()}")
        
        # Get latest Xcode version
        latest_info = get_latest_xcode_version()
        latest_version = latest_info["version"]
        current_version = get_ssm_version()
        
        print(f"Latest Xcode version: {latest_version}")
        print(f"Current stored version: {current_version}")
        
        # Handle first run
        if current_version is None:
            update_ssm_version(latest_version)
            return {
                "statusCode": 200,
                "status": "initial_setup",
                "initial_version": latest_version
            }
        
        # Check if update is needed
        if current_version == latest_version:
            print(f"No update required. Current version {current_version} is latest.")
            return {
                "statusCode": 200,
                "status": "no_update",
                "current_version": current_version
            }
        
        # New version detected
        print(f"New version detected: {latest_version}")
        
        # Check if already downloaded
        if check_s3_file_exists(latest_version):
            print(f"Version {latest_version} already exists in S3")
            update_ssm_version(latest_version)
            return {
                "statusCode": 200,
                "status": "already_downloaded",
                "version": latest_version
            }
        
        # Trigger download
        command_id = trigger_xcode_download(latest_info["download_url"], latest_version)
        
        # Update SSM parameter
        update_ssm_version(latest_version)
        
        # Send notification
        subject = f"New Xcode Version Available: {latest_version}"
        message = f"""New Xcode version detected and download initiated!

Previous Version: {current_version}
New Version: {latest_version}
Download URL: {latest_info['download_url']}
S3 Location: s3://{S3_BUCKET}/xcode-{latest_version}.xip
SSM Command ID: {command_id or 'N/A'}

The download has been initiated on the Mac instance.
You'll receive another notification once the download is complete.
"""
        
        send_notification(subject, message)
        
        return {
            "statusCode": 200,
            "status": "download_initiated",
            "previous_version": current_version,
            "new_version": latest_version,
            "s3_location": f"s3://{S3_BUCKET}/xcode-{latest_version}.xip",
            "command_id": command_id
        }
        
    except Exception as e:
        error_msg = f"Error checking Xcode version: {str(e)}"
        print(error_msg)
        
        send_notification(
            "Xcode Version Check Failed", 
            f"{error_msg}\n\nTimestamp: {datetime.utcnow().isoformat()}"
        )
        
        return {
            "statusCode": 500,
            "status": "error",
            "message": str(e)
        }