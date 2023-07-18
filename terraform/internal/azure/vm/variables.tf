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
  default     = "Standard_F4"
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

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}