# Provider Options

variable "resource_group" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  default     = "westus"
  description = "The location to create resources within."
}

# Network

variable "vpc" {
  type        = string
  description = "The name of the VPC."
}

variable "subnet" {
  type        = string
  description = "The name of the subnet."
}

variable "private_ip_address" {
  type        = string
  description = "The private IP address to assign to this VM. Should be in the VPC's address space."
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS servers that should be used for this virtual network."
  default     = null
}

# Storage

variable "storage_account" {
  type        = string
  description = "The name of the storage account."
}

# Server

variable "name" {
  type        = string
  description = "The name of the virtual machine."
}

variable "size" {
  type        = string
  description = "The size to use for this VM."
  default     = "Standard_B2s"
}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
    os        = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
    os        = "linux"
  }
}

variable "scripts" {
  type        = list(string)
  description = "The scripts to run on this server on boot."
}

# Active Directory

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

# General

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}
