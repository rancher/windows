# Network

variable "name" {
  type        = string
  description = "The name of the server you would like to provision."
}

variable "replicas" {
  type        = number
  description = "Number of replicas of this server to create."
  default     = 1
}

variable "open_ports" {
  type        = list(string)
  description = "Ports to leave on the external (default) subnet."
  default     = []
}

variable "vpc_only_ports" {
  type        = list(string)
  description = "Ports that should only be accessible by other machines in the VPC"
  default     = []
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

variable "domain_join" {
  type        = bool
  description = "Whether to domain join this host or not. Assumed to be false if active_directory is null."
  default     = false
}

variable "image" {
  type        = string
  description = "Image to use for this server."
  default     = "linux"
}

variable "debug_tools" {
  type        = bool
  description = "Whether to install debugging tools (i.e. system-internals, etc.) onto this host. Only supported for Windows hosts today."
  default     = false
}

variable "dev_tools" {
  type        = bool
  description = "Whether to install standard developer tools (i.e. kubectl, git, golang, docker, scoop, etc.) onto this host. Only supported for Windows hosts today."
  default     = false
}

variable "advanced_dev_tools" {
  type        = bool
  description = "Whether to install advanced developer tools (i.e. WSL2, HyperV,  etc.) onto this host. Only supported for Windows hosts today."
  default     = false
}

variable "scripts" {
  type        = list(string)
  description = "The scripts to run on this server on boot."
  default     = []
}

variable "address_space" {
  type        = string
  description = "The address space of the virtual network this server resides in."
  default     = "10.3.0.0/16"
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}