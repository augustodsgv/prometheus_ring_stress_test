output "worker_network_interfaces" {
  value = mgc_virtual_machine_instances.prom_ring_worker[*].network_interfaces[0]
}

output "manager_network_interfaces" {
  value = mgc_virtual_machine_instances.prom_ring_manager[*].network_interfaces[0]
}