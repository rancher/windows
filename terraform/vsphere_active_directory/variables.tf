variable "name" {
  type        = string
  description = "The name of the Active Directory instance you would like to provision."
}

variable "standard_users" {
  type = list(object({
    name     = string
    password = string
  }))
  description = "The set of standard users to include in this ActiveDirectory instance"
  default     = []
}

variable "default_password" {
  type        = string
  description = "The default password to use for all standard users"
  default     = "p@ssw0rd"
}

variable "gmsas" {
  type        = list(string)
  description = "The set of gMSAs to include in this ActiveDirectory instance"
  default     = ["GMSA1"]
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}

variable "windows_script_bundle" {
  type        = string
  description = "the set of scripts that should be installed on the node"
}

# vSphere specific variables

variable "content_library" {
  type = object({
    library = string
    item    = string
  })
}

variable "folder" {
  default = ""
}

variable "connection_details" {
  type = object({
    username            = string
    password            = string
    ssh_key_path        = string
    ssh_public_key_path = string
  })
}

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