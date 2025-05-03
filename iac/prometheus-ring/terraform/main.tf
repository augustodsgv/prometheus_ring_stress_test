terraform {
  required_providers {
    mgc = {
      source  = "MagaluCloud/mgc"
      version = "0.33.0"
    }
  }
}

module "compute" {
  source = "./modules/compute"
  # mgc_api_key = var.mgc_api_key
  worker_count  = var.worker_count
  manager_count = var.manager_count
}

module "network" {
  source = "./modules/network"
  # mgc_api_key = var.mgc_api_key
  worker_count  = var.worker_count
  manager_count = var.manager_count
}

# compute and network attachments
# Public IPs
resource "mgc_network_public_ips_attach" "prom_ring_worker" {
  count        = var.worker_count
  public_ip_id = module.network.worker_public_ips[count.index]
  interface_id = module.compute.worker_network_interfaces[count.index].id
}

resource "mgc_network_public_ips_attach" "prom_ring_manager" {
  count        = var.manager_count
  public_ip_id = module.network.manager_public_ips[count.index]
  interface_id = module.compute.manager_network_interfaces[count.index].id
}

# Security groups
resource "mgc_network_security_groups_attach" "prom_ring_worker" {
  count             = var.worker_count
  security_group_id = module.network.security_group
  interface_id      = module.compute.worker_network_interfaces[count.index].id
}

resource "mgc_network_security_groups_attach" "prom_ring_manager" {
  count             = var.manager_count
  security_group_id = module.network.security_group
  interface_id      = module.compute.manager_network_interfaces[count.index].id
}

module "kubernetes" {
  source = "./modules/kubernetes"
  # mgc_api_key = var.mgc_api_key
}