#!/bin/bash
# modules/ec2-mac/user_data.sh

# Install required tools
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install awscli

# Create download script
cat > /usr/local/bin/download_xcode.sh << 'EOF'
#!/bin/bash
set -e

APPLE_ID=$(aws ssm get-parameter --name "/xcode/apple_id" --with-decryption --query 'Parameter.Value' --output text)
APP_PASSWORD=$(aws ssm get-parameter --name "/xcode/app_password" --with-decryption --query 'Parameter.Value' --output text)
DOWNLOAD_URL="$1"
VERSION="$2"
BUCKET_NAME="${bucket_name}"

echo "Starting Xcode download for version: $VERSION"

# Download Xcode using xcrun
echo "$APP_PASSWORD" | xcrun altool --download-app \
  --username "$APPLE_ID" \
  --password-stdin \
  --download-url "$DOWNLOAD_URL" \
  --output-dir /tmp/

# Find the downloaded file
XIP_FILE=$(find /tmp -name "*.xip" -type f | head -n 1)

if [ -z "$XIP_FILE" ]; then
  echo "ERROR: No XIP file found after download"
  exit 1
fi

# Upload to S3
aws s3 cp "$XIP_FILE" "s3://$BUCKET_NAME/xcode-$VERSION.xip"

# Clean up
rm -f "$XIP_FILE"

echo "Successfully downloaded and uploaded Xcode $VERSION to S3"
EOF

chmod +x /usr/local/bin/download_xcode.sh

# Install SSM Agent (if not already installed)
sudo yum install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent