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
    type       = string
    airgap     = bool
    open_ports = list(number)
  })
  default = {
    type       = "simple"
    airgap     = false
    open_ports = []
  }
}

variable "servers" {
  type = list(object({
    name   = string
    size   = optional(string, "Standard_F4")
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
    scripts = optional(list(string), [])
  }))
  description = "The group of servers you would like to provision."
  default     = []
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}