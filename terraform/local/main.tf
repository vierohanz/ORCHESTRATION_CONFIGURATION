terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

provider "local" {
  # Provider ini bekerja murni di lokal, tanpa butuh AWS, GCP, atau Docker!
}

# Membuat sebuah "Resource" (Sebagai pengganti VM / Server)
# Terraform akan membuat sebuah file konfigurasi server secara fisik.
resource "local_file" "server_config" {
  filename = "${path.module}/server_database_config.txt"
  content  = <<EOF
[Server Configuration]
IP_ADDRESS = 192.168.100.5
ROLE = Database Server
STATUS = Active

# File ini di-generate secara otomatis oleh Terraform!
# Ini mensimulasikan proses 'Provisioning' dari Infrastructure as Code.
EOF
}

output "file_created_at" {
  description = "Lokasi file infrastruktur yang berhasil dibuat"
  value       = local_file.server_config.filename
}
