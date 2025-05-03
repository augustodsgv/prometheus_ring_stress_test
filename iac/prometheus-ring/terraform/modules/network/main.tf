terraform {
  required_providers {
    mgc = {
      source  = "MagaluCloud/mgc"
      version = "0.33.0"
    }
  }
}

# VPC
resource "mgc_network_vpcs" "prom_ring" {
  name        = "prom_ring"
  description = "Prometheus ring vpc"
}

# Network public IPs
## Manager nodes
resource "mgc_network_public_ips" "prom_ring_manager" {
  count       = var.manager_count
  provider    = mgc
  description = "Docker swarm prom_ring_manager ${count.index}"
  vpc_id      = mgc_network_vpcs.prom_ring.id
}

## Worker nodes
resource "mgc_network_public_ips" "prom_ring_worker" {
  count       = var.worker_count
  provider    = mgc
  description = "Docker swarm prom_ring_worker ${count.index}"
  vpc_id      = mgc_network_vpcs.prom_ring.id
}

# Security groups
resource "mgc_network_security_groups" "prom_ring_swarm" {
  provider = mgc
  name     = "prom_ring_swarm"
}

resource "mgc_network_security_groups_rules" "allow_ssh_swarm" {
  provider          = mgc
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.prom_ring_swarm.id
}