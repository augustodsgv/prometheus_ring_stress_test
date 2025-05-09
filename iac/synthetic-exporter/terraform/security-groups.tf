resource "mgc_network_security_groups" "synth_exporter_swarm" {
  provider = mgc
  name = "synth_exporter_swarm"
}

resource "mgc_network_security_groups_rules" "allow_ssh_swarm" {
  provider = mgc
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.synth_exporter_swarm.id
}