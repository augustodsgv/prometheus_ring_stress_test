variable mgc_api_key {
  type        = string
  description = "mgc api key"
}

variable mgc_obj_key_id {
  type        = string
  description = "mgc object key id"
}

variable mgc_obj_key_secret {
  type        = string
  description = "mgc object key secret"
}

variable mgc_region {
  type        = string
  description = "mgc region"
}
variable vpc_id {
  type        = string
  description = "tenant vpc id"
}

variable ssh_key_path {
  type        = string
  default     = "~/.ssh/mgc"
  description = "Path of ssh keys in the host computer. Used to create the VMs and indicated in the ansible file"
}

// Docker Swarm VMs
variable machine_image {
  type        = string
  default     = "cloud-ubuntu-22.04 LTS"
  description = "virtual machine image"
}

variable swarm_machine_type {
  type        = string
  default     = "BV2-4-10"
  description = "swarm node flavor"
}

variable worker_count {
  type        = number
  default     = 0
  description = "number of woker nodes in the cluster"
}

variable manager_count {
  type        = number
  default     = 3 
  description = "number of leader in the cluster"
}

// Kubernetes cluster
variable k8s_cluster_version {
  type    = string
  default = "v1.32.3"
}

variable k8s_nodepool_flavor {
  type    = string
  # default = "cloud-k8s.gp2.large"
  default = "cloud-k8s.gp1.small"
}

variable k8s_nodepool_replicas {
  type    = number
  default = 3
}

// Inventory file for ansible
variable ansible_inventory_dir {
  type = string
  default = "../ansible"
}

