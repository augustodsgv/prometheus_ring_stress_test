variable "k8s_cluster_version" {
  type    = string
  default = "v1.32.3"
}

variable "k8s_mimir_nodepool_flavor" {
  type    = string
  default = "cloud-k8s.gp2.large"
  # default = "cloud-k8s.gp2.small"
}

variable "k8s_mimir_nodepool_replicas" {
  type    = number
  default = 4
}

variable "k8s_metamonitoring_nodepool_flavor" {
  type = string
  default = "cloud-k8s.gp2.small"
}

variable "k8s_metamonitoring_nodepool_replicas" {
  type    = number
  default = 1
}