variable "mgc_api_key" {
  type        = string
  description = "mgc api key"
}

variable "mgc_obj_key_id" {
  type        = string
  description = "mgc object key id"
}

variable "mgc_obj_key_secret" {
  type        = string
  description = "mgc object key secret"
}

variable "mgc_region" {
  type        = string
  description = "mgc region"
}

// Inventory file for ansible
variable "ansible_inventory_path" {
  type    = string
  default = "../ansible"
}

variable "k8s_kubeconfig_path" {
  type    = string
  default = "../k8s"
}

// Docker Swarm machine setup
variable "worker_count" {
  type        = number
  default     = 0
  description = "number of woker nodes in the cluster"
}

variable "manager_count" {
  type        = number
  default     = 0
  description = "number of leader in the cluster"
}