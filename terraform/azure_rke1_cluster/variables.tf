variable "name" {
  type        = string
  description = "The name of the cluster you would like to provision."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of RKE1 that you would like to use to provision a cluster."
  default     = "v1.20.15-rancher2-1"
}

variable "nodes" {
  type = list(object({
    name     = string
    image    = optional(string, "linux")
    size     = optional(string, "Standard_F4")
    scripts  = optional(list(string), [])
    roles    = optional(list(string), ["worker"])
    replicas = optional(number, 1)
  }))
  description = "The pools of nodes that you would like to provision for this cluster."
  default = [
    {
      name     = "linux-server"
      image    = "linux"
      roles    = ["controlplane", "etcd", "worker"]
      replicas = 1
    },
  ]
}

variable "servers" {
  type = list(object({
    name    = string
    image   = optional(string, "linux")
    size    = optional(string, "Standard_F4")
    scripts = optional(list(string), [])
  }))
  description = "Additional servers that should be created alongside your cluster. These servers will automatically be added to the same network as the cluster."
  default     = []
}

variable "open_ports" {
  type        = list(number)
  description = "Ports to leave on the external (default) subnet."
  default     = []
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}
