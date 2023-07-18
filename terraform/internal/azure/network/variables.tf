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
