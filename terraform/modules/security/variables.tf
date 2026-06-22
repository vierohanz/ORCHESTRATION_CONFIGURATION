variable "key_name" {
  description = "Nama SSH Key Pair yang akan didaftarkan ke AWS"
  type        = string
}

variable "public_key_path" {
  description = "Path ke file public key SSH (*.pub)"
  type        = string
}

variable "security_group_name" {
  description = "Nama Security Group (Firewall)"
  type        = string
  default     = "orchest_sg"
}

variable "security_group_description" {
  description = "Deskripsi Security Group"
  type        = string
  default     = "Security Group untuk Orchestration Lab"
}

variable "ingress_rules" {
  description = "Daftar port yang dibuka untuk akses publik"
  type = list(object({
    description = string
    port        = number
  }))
  default = [
    { description = "Allow SSH",                port = 22    },
    { description = "Allow HTTP",               port = 80    },
    { description = "Allow Hazelcast",          port = 5701  },
    { description = "Allow Kubernetes NodePort", port = 30080 },
  ]
}
