variable "name" {
  type        = string
  description = "The name of the group of servers you would like to provision or destroy."
}

variable "common_connection_details" {
  type = object({
    windows_username    = string
    windows_password    = string
    linux_username      = string
    linux_password      = string
    ssh_key_path        = string
    ssh_public_key_path = string
  })
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
      username     = string
      password     = string
      ssh_key_path = string
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

  validation {
    condition = alltrue([for s in var.servers :
    ((s.image.template_path == "" && s.image.content_library != null) || (s.image.template_path != "" && s.image.content_library == null))])
    error_message = "A server can not have both a template_id and content library definition."
  }

  validation {
    condition = alltrue([for s in var.servers :
    ((s.windows_script_bundle != null) && ((s.windows_script_bundle == "dev") || (s.windows_script_bundle == "advancedDev") || (s.windows_script_bundle == "debug") || (s.windows_script_bundle == "")))])
    error_message = "A server can only specify a single available script bundle (dev, advancedDev, debug) or none at all."
  }

  validation {
    condition = alltrue([for s in var.servers :
    ((s.image.os != "linux") || (s.windows_script_bundle == ""))])
    error_message = "Only Windows servers can specify the windows_script_bundle field."
  }

  # TODO: an AD domain is currently required for authentication. Consider refactoring the SQL script to allow for non-domain joined scenarios.
  validation {
    condition = alltrue([for s in var.servers :
    ((s.sql_server_configuration == null) || (s.active_directory_credentials != null))])
    error_message = "A SQL server must join an active directory domain."
  }
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

# provider / vCenter specific options

variable "vsphere_user" {
  sensitive = true
  default   = ""
}

variable "vsphere_password" {
  sensitive = true
  default   = ""
}

variable "vsphere_server" {
  sensitive = true
  default   = ""
}

variable "data_center" {
  type        = string
  description = "The vSphere Datacenter to use"
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