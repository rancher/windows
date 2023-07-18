variable "name" {
  type        = string
  description = "The name of the cluster you would like to provision."
}

variable "registration_commands" {
  type = object({
    linux   = string
    windows = string
  })
  description = "The registration commands for Linux and Windows nodes to be added to this cluster."
}

variable "calicoctl_version" {
  type        = string
  description = "The version of calicoctl to install."
  default     = "v3.19.2"
}

variable "etcdctl_version" {
  type        = string
  description = "The version of etcdctl to install."
  default     = "v3.4.16"
}

variable "docker_version" {
  type        = string
  description = "The version of Docker used for Linux nodes."
  default     = "20.10"
}

variable "nodes" {
  type = list(object({
    name     = string
    os       = string
    roles    = optional(list(string), ["worker"])
    replicas = optional(number, 1)
  }))
  description = "The nodes to create plans for."
}
