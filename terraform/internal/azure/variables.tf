variable "group" {
  type        = string
  description = "The resource group to place all the resources within. Also the prefix used to name all resources."
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

# Provider Options

variable "location" {
  type = string
}

# Network

variable "network" {
  type = object({
    // If disabled, only the external subnet will be created with minimal rules to ssh
    // This will apply for all servers created by this module
    simple = optional(object({
      enabled    = optional(bool, true)
      open_ports = optional(list(number), [])
      }), {
      enabled    = false
      open_ports = []
    })
    template = optional(string, null)
  })

  validation {
    condition     = var.network.simple.enabled || var.network.template != null
    error_message = "Network Template must be provided if simple options are not provided."
  }
}

# Servers

variable "servers" {
  type = list(object({
    name = string
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
    size                = optional(string, "Standard_F2")
    disk_size_gb        = optional(number, null)
    subnet              = optional(string, "external")
    boot_scripts        = list(string)
    registration_script = optional(string, null)
    scripts             = list(string)
  }))
}
