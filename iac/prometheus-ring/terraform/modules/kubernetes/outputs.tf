data "mgc_kubernetes_cluster_kubeconfig" "prom_ring_mimir_kubeconfig" {
  cluster_id = mgc_kubernetes_cluster.prom_ring_mimir.id
}

output "kubeconfig" {
  value = data.mgc_kubernetes_cluster_kubeconfig.prom_ring_mimir_kubeconfig.kubeconfig
}