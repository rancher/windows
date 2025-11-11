variable "name" {
  type        = string
  description = "The name of the cluster you would like to provision."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of RKE2 that you would like to use to provision a cluster."
  default     = "v1.32.5+rke2r1"
}

variable "apps" {
  type = any
  # Due to terraform typing constraint, we cannot impose the following structure
  # since it would require that every field be supplied every time. However, I'm
  # leaving this here purely to document the accepted fields
  # type = map(object({
  #   namespace    = optional(string, "default")
  #   path         = optional(string, "inline")
  #   manifest     = optional(string, null)
  #   values       = optional(any, null)
  #   values_file  = optional(string, null)
  #   dependencies = optional(list(string), [])
  # }))
  description = "Apps deployed as Bundles that will be created by Fleet in the downstream cluster when it is up"
  default     = {}
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

variable "nodes" {
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

    roles = optional(list(string), [])
  }))

  description = "The group of servers you would like to provision or destroy."
  default     = []

  validation {
    condition = alltrue([for s in var.nodes :
    ((s.image.template_path == "" && s.image.content_library != null) || (s.image.template_path != "" && s.image.content_library == null))])
    error_message = "A server can not have both a template_id and content library definition."
  }

  validation {
    condition = alltrue([for s in var.nodes :
    ((s.windows_script_bundle != null) && ((s.windows_script_bundle == "dev") || (s.windows_script_bundle == "advancedDev") || (s.windows_script_bundle == "debug") || (s.windows_script_bundle == "")))])
    error_message = "A server can only specify a single available script bundle (dev, advancedDev, debug) or none at all."
  }
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