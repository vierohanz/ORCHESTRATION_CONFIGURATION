output "webserver_ip" {
  description = "IP Server 1 - Webserver & API"
  value       = module.ubuntu_1.instance_public_ip
}

output "k3s_node_ip" {
  description = "IP Server 2 - Kubernetes Node"
  value       = module.ubuntu_2.instance_public_ip
}

output "cache_server_ip" {
  description = "IP Server 3 - Hazelcast Cache"
  value       = module.ubuntu_3.instance_public_ip
}

output "web_url" {
  description = "URL aplikasi Kalkulator"
  value       = "http://${module.ubuntu_1.instance_public_ip}"
}

output "k3s_hello_world_url" {
  description = "URL Hello World Kubernetes"
  value       = "http://${module.ubuntu_2.instance_public_ip}:30080"
}
