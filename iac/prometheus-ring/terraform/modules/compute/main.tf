terraform {
  required_providers {
    mgc = {
      source  = "MagaluCloud/mgc"
      version = "0.33.0"
    }
  }
}

# SSH key
resource "mgc_ssh_keys" "prom_ring_key" {
  provider = mgc
  key      = file("${var.ssh_key_path}.pub")
  name     = "prom_ring_key"
}

# Docker swarm manager nodes
resource "mgc_virtual_machine_instances" "prom_ring_manager" {
  provider     = mgc
  count        = var.manager_count
  name         = "prom_ring_manager_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.prom_ring_key.name
}

# Docker swarm worker nodes
resource "mgc_virtual_machine_instances" "prom_ring_worker" {
  provider     = mgc
  count        = var.worker_count
  name         = "prom_ring_worker_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.prom_ring_key.name
}

