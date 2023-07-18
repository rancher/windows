variable "type" {
  type        = string
  description = "Type of network to create."
  default     = "simple"

  validation {
    condition     = contains(["simple", "rke2-calico", "rke1-flannel"], var.type)
    error_message = "Network type is not defined: expected 'simple', 'rke2-calico', or 'rke1-flannel'."
  }
}

variable "airgap" {
  type        = bool
  description = "Disable all outbound connections."
  default     = false
}

variable "open_ports" {
  type        = list(number)
  description = "Ports to leave on the external (default) subnet."
  default     = []
}

variable "vpc" {
  type = object({
    address_space = string
  })
  description = "The name of the VPC."
  default = {
    address_space = "10.0.0.0/16"
  }
}

variable "subnets" {
  type = object({
    external = object({
      address_space = string
      roles         = list(string)
    })
    controlplane = object({
      address_space = string
      roles         = list(string)
    })
    etcd = object({
      address_space = string
      roles         = list(string)
    })
    worker = object({
      address_space = string
      roles         = list(string)
    })
    controlplane-etcd = object({
      address_space = string
      roles         = list(string)
    })
    controlplane-worker = object({
      address_space = string
      roles         = list(string)
    })
    controlplane-etcd-worker = object({
      address_space = string
      roles         = list(string)
    })
    etcd-worker = object({
      address_space = string
      roles         = list(string)
    })
  })

  description = "The subnets to create."

  default = {
    external = {
      address_space = "10.0.224.0/19"
      roles         = null
    }
    controlplane = {
      address_space = "10.0.32.0/19"
      roles         = ["controlplane"]
    }
    etcd = {
      address_space = "10.0.0.0/19"
      roles         = ["etcd"]
    }
    worker = {
      address_space = "10.0.64.0/19"
      roles         = ["worker"]
    }
    controlplane-etcd = {
      address_space = "10.0.96.0/19"
      roles         = ["controlplane", "etcd"]
    }
    controlplane-worker = {
      address_space = "10.0.160.0/19"
      roles         = ["controlplane", "worker"]
    }
    etcd-worker = {
      address_space = "10.0.128.0/19"
      roles         = ["etcd", "worker"]
    }
    controlplane-etcd-worker = {
      address_space = "10.0.192.0/19"
      roles         = ["controlplane", "etcd", "worker"]
    }
  }

  validation {
    condition     = [for subnet in var.subnets : subnet.roles != null ? sum([for role in subnet.roles : contains(["etcd", "controlplane", "worker"], role) ? 0 : 1]) : 0] != 0
    error_message = "If roles are defined, they must be 'etcd', 'controlplane', or 'worker'."
  }
}