variable "common_connection_details" {
  type = object({
    windows_username    = string
    windows_password    = string
    linux_username      = string
    linux_password      = string
    ssh_key_path        = string
    ssh_public_key_path = string
  })
  default = null
}

variable "servers" {
  type = list(object({
    name = string

    cpu_count    = number
    memory_in_mb = number
    disk_size    = number
    guest_id     = string
    domain_join  = optional(bool, false)
    replicas     = number
    folder       = string

    scripts = optional(list(object({
      content = string
      name    = string
      execute = optional(bool, false)
    })), null)

    windows_script_bundle = optional(string, "")

    image = optional(object({
      content_library = optional(object({
        library = string
        item    = string
      }), null)
      template_path = optional(string, "")
      os            = string
    }), null)

    connection_details = optional(object({
      username            = string
      password            = string
      ssh_key_path        = string
      ssh_public_key_path = string
    }), null)

    active_directory_credentials = optional(object({
      username = string
      password = string
    }), null)

    sql_server_configuration = optional(object({
      database_name = string
      table_name    = string
    }), null)
  }))
  description = "The group of servers you would like to provision or destroy."
  default     = []
}

variable "active_directory" {
  type = object({
    domain_name         = string
    domain_netbios_name = string
    ip_address          = string
  })
  description = "Values to integrate with ActiveDirectory module."
  default     = null
}

# Provider / vCenter options

variable "data_center" {
  type        = string
  description = "The vSphere Datacenter to use"
  default     = ""
}

variable "datastore" {
  type = string
}

variable "compute_cluster" {
  type = string
}

variable "network" {
  type = string
}

variable "resource_pool" {
  default = ""
}