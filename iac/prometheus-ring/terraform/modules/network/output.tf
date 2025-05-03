output "manager_public_ips" {
  value = mgc_network_public_ips.prom_ring_manager[*].id
}

output "worker_public_ips" {
  value = mgc_network_public_ips.prom_ring_worker[*].id
}

output "security_group" {
  value = mgc_network_security_groups.prom_ring_swarm.id
}