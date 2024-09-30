variable "name" {
  type        = string
  description = "The name of the cluster you would like to provision."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of RKE2 that you would like to use to provision a cluster."
  default     = "v1.30.9+rke2r1"
}
