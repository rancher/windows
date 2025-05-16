# Provider Options

variable "resource_group" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  default     = "westus"
  description = "The location to create resources within."
}

# Network

variable "type" {
  type        = string
  description = "The type of network to provision."
}

variable "address_space" {
  type        = string
  description = "The address space of the VPC"
  default     = "10.0.0.0/16"
}

variable "airgap" {
  type        = bool
  description = "Disable all outbound connections."
  default     = false
}

variable "vpc_only_ports" {
  type        = list(string)
  description = "List of ports and/or port ranges that should only be accessible from other machines in the VPC."
  default     = []
}

variable "open_ports" {
  type        = list(string)
  description = "Ports to leave on the external (default) subnet."
  default     = []
}

variable "peers" {
  type = map(object({
    resource_group = optional(string, null)
  }))
  description = "Additional virtual networks to create a peering relationship with."
  default     = {}
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS servers that should be used for this virtual network."
  default     = null
}
