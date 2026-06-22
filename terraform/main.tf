module "security" {
  source = "./modules/security"

  key_name        = var.key_name
  public_key_path = "${path.module}/orchest_key.pub"

  security_group_name        = var.security_group_name
  security_group_description = "Security Group untuk Orchestration Lab"
  ingress_rules              = var.ingress_rules
}

# Server 1: Webserver + API Calculator
module "ubuntu_1" {
  source = "./modules/compute"

  server_name        = "orchest_ubuntu_1"
  instance_type      = var.instance_type
  storage_size       = var.storage_size
  key_name           = module.security.key_name
  security_group_ids = [module.security.security_group_id]
}

# Server 2: Kubernetes Node (K3s)
module "ubuntu_2" {
  source = "./modules/compute"

  server_name        = "orchest_ubuntu_2"
  instance_type      = var.instance_type
  storage_size       = var.storage_size
  key_name           = module.security.key_name
  security_group_ids = [module.security.security_group_id]
}

# Server 3: Cache Server (Hazelcast)
module "ubuntu_3" {
  source = "./modules/compute"

  server_name        = "orchest_ubuntu_3"
  instance_type      = var.instance_type
  storage_size       = var.storage_size
  key_name           = module.security.key_name
  security_group_ids = [module.security.security_group_id]
}
