variable "ssh_key_path" {
  type        = string
  default     = "~/.ssh/mgc"
  description = "Path of ssh keys in the host computer. Used to create the VMs and indicated in the ansible file"
}

variable "machine_image" {
  type        = string
  default     = "cloud-ubuntu-22.04 LTS"
  description = "virtual machine image"
}

variable "swarm_machine_type" {
  type        = string
  # default     = "BV2-4-10"
  default     = "BV4-8-20"
  description = "swarm node flavor"
}

variable "worker_count" {
  type        = number
  default     = 0
  description = "number of woker nodes in the cluster"
}

variable "manager_count" {
  type        = number
  default     = 3
  description = "number of leader in the cluster"
}