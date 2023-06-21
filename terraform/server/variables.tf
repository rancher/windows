variable "name" {
  type = string
}

variable "server" {
  type = object({
    name         = string
    image        = optional(string, null)
    disk_size_gb = optional(number, null)
    size         = optional(string, null)
    boot_scripts = optional(list(string), [])
    scripts      = optional(list(string), [])
    open_ports   = optional(list(number), [])
  })
  default = {
    name  = "linux"
    image = "linux"
  }
}

variable "infrastructure" {
  type = object({
    azure = object({
      enabled  = optional(bool, false)
      location = optional(string, "West US")
    })
  })
  default = {
    azure = {
      enabled = true
    }
  }

  validation {
    condition     = sum([for provider in var.infrastructure : provider.enabled ? 1 : 0]) == 1
    error_message = "Exactly one provider must be enabled to provision infrastructure."
  }
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
