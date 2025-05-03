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