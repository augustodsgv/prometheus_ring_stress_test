output "prom_ring_managers_ips" {
  value = {
    for idx, nic in module.compute.manager_network_interfaces:
    "manager-${idx}" => {
      public_ip  = nic.ipv4,
      private_ip = nic.local_ipv4
    }
  }
}

output "prom_ring_workers_ips" {
  value = {
    for idx, nic in module.compute.worker_network_interfaces :
    "worker-${idx}" => {
      public_ip  = nic.ipv4,
      private_ip = nic.local_ipv4
    }
  }
}

# Builds an ansible inventory file from inventory.yaml.tmpl
locals {
  managers = {
    for idx, nic in module.compute.manager_network_interfaces:
    "manager-${idx}" => {
      public_ip  = nic.ipv4,
      private_ip = nic.local_ipv4
    }
  }

  workers = {
    for idx, nic in module.compute.worker_network_interfaces :
    "worker-${idx}" => {
      public_ip  = nic.ipv4,
      private_ip = nic.local_ipv4
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
resource "local_file" "prom_ring_mimir_kubeconfig" {
  filename = "${var.k8s_kubeconfig_path}/kubeconfig.yaml"
  content = module.kubernetes.kubeconfig
}