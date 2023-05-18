variable "cluster" {
  type = object({
    name         = string
    distribution = string
    cni          = string

    linux_registration_command   = string
    windows_registration_command = string

    machine_pools = list(object({
      name         = string
      image        = optional(string, null)
      size         = optional(string, null)
      disk_size_gb = optional(number, null)
      scripts      = optional(list(string), [])
      boot_scripts = optional(list(string), [])
      roles        = optional(list(string), ["worker"])
      replicas     = optional(number, 1)
    }))

    servers = optional(list(object({
      name         = string
      image        = optional(string, null)
      size         = optional(string, null)
      disk_size_gb = optional(number, null)
      scripts      = optional(list(string), [])
      boot_scripts = optional(list(string), [])
    })), [])
  })
}

variable "infrastructure" {
  type = object({
    azure = object({
      enabled  = optional(bool, false)
      location = optional(string, "West US")
    })
  })

  validation {
    condition     = sum([for provider in var.infrastructure : provider.enabled ? 1 : 0]) == 1
    error_message = "Exactly one provider must be enabled to provision infrastructure."
  }
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
