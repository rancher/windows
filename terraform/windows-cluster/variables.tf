variable "name" {
  type        = string
  description = "The name of the cluster you would like to provision."
}

variable "distribution" {
  type        = string
  description = "The distribution to use for this cluster"
  default     = "rke2"

  validation {
    condition     = contains(["rke1", "rke2"], var.distribution)
    error_message = "Only RKE1 and RKE2 clusters are supported."
  }
}

variable "rke1_version" {
  type        = string
  description = "The version of RKE1 that you would like to use to provision a cluster."
  default     = "v1.23.16-rancher2-21"
}

variable "docker_version" {
  type        = string
  description = "The version of Docker used for nodes. Only used if nodes are RKE1."
  default     = "20.10"
}

variable "rke2_version" {
  type        = string
  description = "The version of RKE2 that you would like to use to provision a cluster."
  default     = "v1.24.13+rke2r1"
}

variable "fleet_workspace" {
  type        = string
  description = "The Fleet workspace to place this cluster into,"
  default     = "fleet-default"
}

variable "cni" {
  type        = string
  description = "The CNI you would like to use for this cluster"
  default     = "calico"
}

variable "nodes" {
  type = list(object({
    name         = string
    image        = optional(string, null)
    size         = optional(string, null)
    disk_size_gb = optional(number, null)
    scripts      = optional(list(string), [])
    boot_scripts = optional(list(string), [])
    roles        = optional(list(string), ["worker"])
    replicas     = optional(number, 1)
  }))
  description = "The pools of nodes that you would like to provision for this cluster."
  default = [
    {
      name     = "server"
      image    = "linux"
      roles    = ["controlplane", "etcd", "worker"]
      replicas = 1
    },
    {
      name     = "windows"
      image    = "windows"
      roles    = ["worker"]
      replicas = 1
    }
  ]
}

variable "infrastructure" {
  type = object({
    azure = optional(object({
      enabled  = optional(bool, false)
      location = optional(string, "West US")
    }))
  })
  description = "Additional options to be provided to a supported cloud provider."
  default = {
    azure = {
      enabled = true
    }
  }
}

variable "additional_servers" {
  type = list(object({
    name         = string
    image        = optional(string, null)
    size         = optional(string, null)
    disk_size_gb = optional(number, null)
    scripts      = optional(list(string), [])
    boot_scripts = optional(list(string), [])
  }))
  description = "Additional servers that should be created alongside your cluster. These servers will automatically be added to the same network as the cluster."
  default     = []
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to the SSH key that should be mounted to all hosts to allow easy access to SSH into hosts."
  default     = "~/.ssh/id_rsa.pub"
}
