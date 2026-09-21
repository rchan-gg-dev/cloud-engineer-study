output "public_ec2_instance_id" {
  description = "Instance ID of the public EC2"
  value       = aws_instance.public.id
}

output "public_ec2_public_ip" {
  description = "Public IPv4 address of the public EC2"
  value       = aws_instance.public.public_ip
  sensitive   = true
}

output "public_ec2_private_ip" {
  description = "Private IPv4 address of the public EC2"
  value       = aws_instance.public.private_ip
}