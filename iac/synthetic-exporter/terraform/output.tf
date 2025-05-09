output "synth_exporter_managers_ips" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.synth_exporter_manager :
    "manager-${idx}" => {
      public_ip  = vm.network_interfaces[0].ipv4,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }
}

output "synth_exporter_workers_ips" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.synth_exporter_worker :
    "worker-${idx}" => {
      public_ip  = vm.network_interfaces[0].ipv4
      private_ip = vm.network_interfaces[0].local_ipv4
    }
    if length(mgc_virtual_machine_instances.synth_exporter_worker) > 0
  }
}

# Builds an ansible inventory file from inventory.yaml.tmpl
locals {
  managers = {
    for idx, vm in mgc_virtual_machine_instances.synth_exporter_manager :
    "manager-${idx}" => {
      public_ip  = vm.network_interfaces[0].ipv4,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }

  workers = {
    for idx, vm in mgc_virtual_machine_instances.synth_exporter_worker :
    "worker-${idx}" => {
      public_ip  = vm.network_interfaces[0].ipv4,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
    if length(mgc_virtual_machine_instances.synth_exporter_worker) > 0
  }
  
}

resource "local_file" "ansible_inventory" {
  filename = "${var.ansible_inventory_path}/inventory.yaml"
  content = templatefile("${path.module}/inventory.yaml.tmpl", {
    managers = local.managers
    workers  = local.workers
  })
}