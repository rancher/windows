variable "infrastructure_provider" {
  type = string

  validation {
    condition     = contains(["azure"], var.infrastructure_provider)
    error_message = "Provider does not have any images available."
  }
}
