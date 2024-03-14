variable "name" {
  type        = string
  description = "The name of the cluster you would like to provision."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of RKE2 that you would like to use to provision a cluster."
  default     = "v1.25.16+rke2r1"
}

variable "active_directory" {
  type = object({
    name                = string
    domain_name         = string
    domain_netbios_name = string
    ip_address          = string
    join_credentials = object({
      username = string
      password = string
    })
  })
  description = "Values to integrate with ActiveDirectory module."
  default     = null
}

variable "apps" {
  type = any
  # Due to terraform typing constraint, we cannot impose the following structure
  # since it would require that every field be supplied every time. However, I'm
  # leaving this here purely to document the accepted fields
  # type = map(object({
  #   namespace    = optional(string, "default")
  #   path         = optional(string, "inline")
  #   manifest     = optional(string, null)
  #   values       = optional(any, null)
  #   values_file  = optional(string, null)
  #   dependencies = optional(list(string), [])
  # }))
  description = "Apps deployed as Bundles that will be created by Fleet in the downstream cluster when it is up"
  default     = {}
}

variable "nodes" {
  type = list(object({
    name        = string
    image       = optional(string, "linux")
    size        = optional(string, "Standard_B2als_v2")
    scripts     = optional(list(string), [])
    roles       = optional(list(string), ["worker"])
    replicas    = optional(number, 1)
    domain_join = optional(bool, false)
  }))
  description = "The pools of nodes that you would like to provision for this cluster."
  default = [
    {
      name     = "linux-server"
      image    = "linux"
      size     = "Standard_B4als_v2"
      roles    = ["controlplane", "etcd", "worker"]
      replicas = 1
    },
    {
      name     = "windows-server"
      image    = "windows"
      roles    = ["worker"]
      replicas = 1
    }
  ]
}

variable "servers" {
  type = list(object({
    name        = string
    image       = optional(string, "linux")
    size        = optional(string, "Standard_B2als_v2")
    scripts     = optional(list(string), [])
    domain_join = optional(bool, false)
  }))
  description = "Additional servers that should be created alongside your cluster. These servers will automatically be added to the same network as the cluster."
  default     = []
}

variable "open_ports" {
  type        = list(string)
  description = "Ports to leave on the external (default) subnet."
  default     = []
}

variable "address_space" {
  type        = string
  description = "The address space of the virtual network this cluster resides in."
  default     = "10.2.0.0/16"
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts. This must be a RSA public key."
  default     = "~/.ssh/id_rsa.pub"
}
