variable "name" {
  type        = string
  description = "The name of the Rancher instance you would like to provision."

  validation {
    condition     = endswith(var.name, "-rancher")
    error_message = "Name must end with -rancher"
  }
}

variable "size" {
  type        = string
  description = "Default size to use for the single server this Rancher instance will run on."
  default     = "Standard_B4als_v2"
}

variable "rancher_version" {
  type        = string
  description = "Version of Rancher to use. Find this on https://hub.docker.com/r/rancher/rancher."
  default     = "2.8.1"
}

variable "create_record" {
  type        = bool
  description = "Whether to create a DigitalOcean record pointing to the Rancher instance's IP. This is only intended for Rancher internal use-cases."
  default     = false
}

variable "replace" {
  type        = bool
  description = "Whether to replace this Rancher on the next apply with a different configuration. Default is that it continues to use the same volume mount as before."
  default     = false
}

variable "registry_hostname" {
  type        = string
  description = "The hostname to use for the Docker image (i.e. if you supply 'clippy' here, the Rancher image used will be 'clippy/rancher' with the tag specified by the rancher_version var)."
  default     = "rancher"
}

variable "docker_version" {
  type        = string
  default     = "23.0"
  description = "Version of Docker to run Rancher on. Find this in https://github.com/rancher/install-docker/tree/master/dist."
}

variable "address_space" {
  type        = string
  description = "The address space of the virtual network this Rancher instance resides in"
  default     = "10.1.0.0/16"
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}

