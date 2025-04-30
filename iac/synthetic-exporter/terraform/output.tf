output "synth_exporter_managers_ips" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.synth_exporter_manager :
    "manager-${idx}" => {
      public_ip  = mgc_network_public_ips.synth_exporter_manager[idx].public_ip,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }
}

output "synth_exporter_workers_ips" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.synth_exporter_worker :
    "worker-${idx}" => {
      public_ip  = mgc_network_public_ips.synth_exporter_worker[idx].public_ip,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }
}
