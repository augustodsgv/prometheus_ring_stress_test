terraform {
  required_providers {
    mgc = {
      source = "MagaluCloud/mgc"
      version = "0.32.2"
    }
  }
}

# SSH key
resource "mgc_ssh_keys" "synth_exporter_key" {
  provider = mgc
  key  = file(var.ssh_key_path)
  name = "synth_exporter_key"
}

# Worker nodes
resource "mgc_virtual_machine_instances" "synth_exporter_worker" {
  provider = mgc
  count = var.worker_count
  name         = "synth_exporter_worker_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.synth_exporter_key.name
}

resource "mgc_network_public_ips" "synth_exporter_worker" {
  count = var.worker_count
  provider = mgc
  description = "Docker swarm synth_exporter_worker ${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "synth_exporter_worker" {
  provider = mgc
  count = var.worker_count
  public_ip_id = mgc_network_public_ips.synth_exporter_worker[count.index].id
  interface_id = mgc_virtual_machine_instances.synth_exporter_worker[count.index].network_interfaces[0].id
}

resource "mgc_network_security_groups_attach" "synth_exporter_worker" {
  provider = mgc
  count = var.worker_count
  security_group_id = mgc_network_security_groups.synth_exporter_swarm.id
  interface_id = mgc_virtual_machine_instances.synth_exporter_worker[count.index].network_interfaces[0].id
}

# Manager nodes
resource "mgc_virtual_machine_instances" "synth_exporter_manager" {
  provider = mgc
  count = var.manager_count
  name         = "synth_exporter_manager_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.synth_exporter_key.name
}

resource "mgc_network_public_ips" "synth_exporter_manager" {
  count = var.manager_count
  provider = mgc
  description = "Docker swarm synth_exporter_manager ${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "synth_exporter_manager" {
  provider = mgc
  count = var.manager_count
  public_ip_id = mgc_network_public_ips.synth_exporter_manager[count.index].id
  interface_id = mgc_virtual_machine_instances.synth_exporter_manager[count.index].network_interfaces[0].id
}

resource "mgc_network_security_groups_attach" "synth_exporter_manager" {
  provider = mgc
  count = var.manager_count
  security_group_id = mgc_network_security_groups.synth_exporter_swarm.id
  interface_id = mgc_virtual_machine_instances.synth_exporter_manager[count.index].network_interfaces[0].id
}