variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Tipe instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "storage_size" {
  description = "Ukuran storage (GB)"
  type        = number
  default     = 10
}

variable "key_name" {
  description = "Nama SSH Key Pair"
  type        = string
  default     = "orchest_key_v2"
}

variable "security_group_name" {
  description = "Nama Security Group"
  type        = string
  default     = "orchest_sg"
}

variable "ingress_rules" {
  description = "Daftar port yang dibuka"
  type = list(object({
    description = string
    port        = number
  }))
  default = [
    { description = "Allow SSH",                 port = 22    },
    { description = "Allow HTTP",                port = 80    },
    { description = "Allow Hazelcast",           port = 5701  },
    { description = "Allow Kubernetes NodePort", port = 30080 },
  ]
}
