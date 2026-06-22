output "key_name" {
  description = "Nama SSH Key Pair yang sudah terdaftar di AWS"
  value       = aws_key_pair.this.key_name
}

output "security_group_id" {
  description = "ID Security Group yang bisa dipakai oleh EC2"
  value       = aws_security_group.this.id
}
