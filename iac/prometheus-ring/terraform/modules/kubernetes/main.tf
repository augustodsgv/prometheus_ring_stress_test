terraform {
  required_providers {
    mgc = {
      source  = "MagaluCloud/mgc"
      version = "0.33.0"
    }
  }
}

resource "mgc_kubernetes_cluster" "prom_ring_mimir" {
  name                 = "prom-ring-mimir"
  version              = var.k8s_cluster_version
  enabled_server_group = false
  description          = "Cluster for mimir deployment"
}

resource "mgc_kubernetes_nodepool" "prom_ring_mimir" {
  name        = "prom-ring-mimir"
  depends_on  = [mgc_kubernetes_cluster.prom_ring_mimir]
  cluster_id  = mgc_kubernetes_cluster.prom_ring_mimir.id
  flavor_name = var.k8s_mimir_nodepool_flavor
  replicas    = var.k8s_mimir_nodepool_replicas
  taints = [{
      effect = "NoSchedule"
      key    = "role"
      value  = "mimir"
  }]
}

resource "mgc_kubernetes_nodepool" "prom_ring_metamonitoring" {
  name        = "prom-ring-metamonitoring"
  depends_on  = [mgc_kubernetes_cluster.prom_ring_mimir]
  cluster_id  = mgc_kubernetes_cluster.prom_ring_mimir.id
  flavor_name = var.k8s_metamonitoring_nodepool_flavor
  replicas    = var.k8s_metamonitoring_nodepool_replicas
}