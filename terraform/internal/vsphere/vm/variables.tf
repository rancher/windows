locals {
  all_scripts = var.os == "windows" ? var.scripts != null ? concat([{
    # TODO: This approach should be reevaluated for something more dynamic
    content = templatefile(
      "${path.module}/files/add_scheduled_tasks.ps1",
      {
        scripts = join(", ", [for k, v in var.scripts : "\"${v.name}\""])
      }
    )
    name    = "add_scheduled_tasks.ps1"
    execute = true
  }], var.scripts) : [] : var.scripts
}

variable "name" {
  type        = string
  description = "The name of the virtual machine."
}

variable "cpu_count" {
  description = "The number of vCPU's to use."
  type        = number
}

variable "memory_in_mb" {
  description = "The amount of memory in megabytes to use."
  type        = number
}

variable "disk_size" {
  description = "The disk size in gigabytes to use."
  type        = number
}

variable "guest_id" {
  description = "An OS specific identifier. Refer to vSphere documentation on the correct value to use here."
  type        = string
}

variable "folder" {
  description = "The folder where the VM will be placed in. Relative to the datacenter path."
  type        = string
}

variable "os" {
  description = "Indicates if the OS is a linux or windows box."
  type        = string
}

variable "connection_details" {
  description = "Describes how to connect to the remote VM when deploying scripts and executing bootstrapping commands"
  type = object({
    username            = string
    password            = string
    ssh_key_path        = string
    ssh_public_key_path = string
  })
  default = null
}

variable "scripts" {
  type = list(object({
    content = string
    name    = string
    execute = optional(bool, false)
  }))
  default = null
}

variable "image" {
  description = "The vSphere image to deploy onto the VM"
  type = object({
    content_library = optional(object({
      library = string
      item    = string
    }), null)
    template_path = optional(string, "")
    os            = string
  })
  default = null
}

# Provider / vCenter options

variable "data_center" {
  type        = string
  description = "The vSphere Datacenter to use"
  default     = ""
}

variable "datastore" {
  description = "The specific vSphere Datacenter to use. This cannot be a Datastore cluster."
  type        = string
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



