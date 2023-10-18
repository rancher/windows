# Provider Options

variable "location" {
  type        = string
  default     = "westus"
  description = "The location to create resources within."
}

# Servers

variable "name" {
  type        = string
  description = "The name of the group of servers you would like to provision."
}

variable "network" {
  type = object({
    type          = string
    address_space = string
    airgap        = bool
    open_ports    = list(string)
  })
  default = {
    type          = "simple"
    address_space = "10.0.256.0/16"
    airgap        = false
    open_ports    = []
  }
}

variable "servers" {
  type = list(object({
    name   = string
    size   = optional(string, "Standard_B2als_v2")
    subnet = optional(string, "external")
    image = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
      os        = string
      }), {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
      os        = "linux"
    })
    scripts     = optional(list(string), [])
    domain_join = optional(bool, false)
  }))
  description = "The group of servers you would like to provision."
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

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}
