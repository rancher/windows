variable "name" {
  type        = string
  description = "The name of the cluster you would like to provision."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of RKE1 that you would like to use to provision a cluster."
  default     = "v1.23.16-rancher2-21"
}

variable "windows_cluster" {
  type        = bool
  description = "Whether this cluster will have Windows nodes."
  # Note: Should never be enabled. Windows clusters are no longer supported.
  default = false
}

