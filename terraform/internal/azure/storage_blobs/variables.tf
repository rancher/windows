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

# Storage

variable "storage_account" {
  type        = string
  description = "The name of the storage account."
}

# Storage Container

variable "storage_container" {
  type        = string
  description = "The name of the storage container."
}

variable "blobs" {
  type        = map(string)
  description = "The blobs to add to the container."
}