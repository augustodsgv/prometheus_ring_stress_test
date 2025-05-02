output "prom_ring_managers_ips" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.prom_ring_manager :
    "manager-${idx}" => {
      public_ip  = mgc_network_public_ips.prom_ring_manager[idx].public_ip,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }
}

output "prom_ring_workers_ips" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.prom_ring_worker :
    "worker-${idx}" => {
      public_ip  = mgc_network_public_ips.prom_ring_worker[idx].public_ip,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }
}

# Builds an ansible inventory file from inventory.yaml.tmpl
locals {
  managers = {
    for idx, vm in mgc_virtual_machine_instances.prom_ring_manager :
    "manager-${idx}" => {
      public_ip  = mgc_network_public_ips.prom_ring_manager[idx].public_ip,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }

  workers = {
    for idx, vm in mgc_virtual_machine_instances.prom_ring_worker :
    "worker-${idx}" => {
      public_ip  = mgc_network_public_ips.prom_ring_worker[idx].public_ip,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${var.ansible_inventory_path}/inventory.yaml"
  content  = templatefile("${path.module}/inventory.yaml.tmpl", {
    managers = local.managers
    workers  = local.workers
  })
}

# Gets the k8s cluster kubeconfig
data "mgc_kubernetes_cluster_kubeconfig" "prom_ring_mimir"{
  cluster_id = mgc_kubernetes_cluster.prom_ring_mimir.id
}

resource "local_file" "prom_ring_mimir_kubeconfig" {
  filename = "${var.k8s_kubeconfig_path}/kubeconfig.yaml"
  content = data.mgc_kubernetes_cluster_kubeconfig.prom_ring_mimir.kubeconfig
}