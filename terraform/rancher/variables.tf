variable "name" {
  type        = string
  description = "The prefix to add to any resources you create for this Rancher instance."
}

variable "rancher_version" {
  type        = string
  description = "Version of Rancher to use. Find this on https://hub.docker.com/r/rancher/rancher."
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
  description = "The hostname to use for the Docker image (i.e. if you supply 'clippy' here, the Rancher image used will be 'clippy/rancher' with the tag specified by the rancher_version var)"
  default     = "rancher"
}

variable "docker_version" {
  type        = string
  default     = "20.10"
  description = "Version of Docker to run Rancher on. Find this in https://github.com/rancher/install-docker/tree/master/dist."
}

variable "infrastructure" {
  type = object({
    azure = optional(object({
      enabled  = optional(bool, false)
      location = optional(string, "West US")
    }))
  })
  description = "Additional options to be provided to a supported cloud provider."
  default = {
    azure = {
      enabled = true
    }
  }
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to the SSH key that should be mounted to all hosts to allow easy access to SSH into hosts."
  default     = "~/.ssh/id_rsa.pub"
}

