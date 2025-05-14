variable "type" {
  type        = string
  description = "Type of network to create."
  default     = "simple"

  validation {
    condition     = contains(["simple", "rke2-calico", "rke1-flannel"], var.type)
    error_message = "Network type is not defined: expected 'simple', 'rke2-calico', or 'rke1-flannel'."
  }
}

variable "address_space" {
  type        = string
  description = "The address space of the virtual network."
  default     = "10.0.0.0/16"

  validation {
    condition     = can(regex("^10\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\\.0\\.0\\/16$", var.address_space))
    error_message = "Address space must be IPv4 CIDR matching the format 10.X.0.0/16."
  }
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
