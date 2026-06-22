variable "instance_type" {
  description = "Tipe instance EC2 (menentukan CPU dan RAM)"
  type        = string
  default     = "t3.small" # 2 vCPU, 2GB RAM
}

variable "storage_size" {
  description = "Ukuran storage dalam satuan GB"
  type        = number
  default     = 40
}

variable "server_name" {
  description = "Nama instance"
  type        = string
}

variable "key_name" {
  description = "Nama SSH Key untuk login"
  type        = string
}

variable "security_group_ids" {
  description = "List Security Group ID untuk firewall"
  type        = list(string)
}
