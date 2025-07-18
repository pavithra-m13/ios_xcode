data "aws_ami" "mac_os" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn-ec2-macos-*"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
resource "aws_ec2_host" "mac_host" {
  availability_zone = var.availability_zone         
  instance_type     = var.instance_type             
  host_recovery     = "on"
  auto_placement    = "on"

  tags = var.tags
}

resource "aws_key_pair" "mac_instance" {
  key_name   = "${var.instance_name}-key"
  public_key = var.public_key
  tags       = var.tags
}

resource "aws_security_group" "mac_instance" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Mac instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_iam_role" "mac_instance" {
  name = "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "mac_instance" {
  name = "${var.instance_name}-policy"
  role = aws_iam_role.mac_instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:UpdateInstanceInformation",
          "ssm:SendCommand"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mac_instance_ssm" {
  role       = aws_iam_role.mac_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "mac_instance" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.mac_instance.name
}

resource "aws_instance" "mac_instance" {
  ami                    = data.aws_ami.mac_os.id
  instance_type          = var.instance_type              
  key_name               = aws_key_pair.mac_instance.key_name
  vpc_security_group_ids = [aws_security_group.mac_instance.id]
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.mac_instance.name
  tenancy                = "host"                          # must be 'host' for macOS
  host_id                = aws_ec2_host.mac_host.id        # assign dedicated host

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    bucket_name = var.s3_bucket_name
  }))

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}
