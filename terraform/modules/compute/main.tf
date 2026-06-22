# Mencari AMI Ubuntu 22.04 terbaru secara otomatis
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID resmi milik Canonical (pembuat Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type # Nilai akan diambil dari main.tf
  key_name      = var.key_name
  vpc_security_group_ids = var.security_group_ids

  # Konfigurasi Storage (Hardisk)
  root_block_device {
    volume_size = var.storage_size
    volume_type = "gp3" # Tipe SSD terbaru dan lebih murah dari gp2
  }

  tags = {
    Name = var.server_name
  }
}
