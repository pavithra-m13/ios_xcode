output "instance_id" {
  description = "ID of the Mac instance"
  value       = aws_instance.mac_instance.id
}

output "public_ip" {
  description = "Public IP of the Mac instance"
  value       = aws_instance.mac_instance.public_ip
}

output "private_ip" {
  description = "Private IP of the Mac instance"
  value       = aws_instance.mac_instance.private_ip
}