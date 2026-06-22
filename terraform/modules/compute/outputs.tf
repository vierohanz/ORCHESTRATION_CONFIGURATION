output "instance_public_ip" {
  description = "IP Publik dari server"
  value       = aws_instance.server.public_ip
}
