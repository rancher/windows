# Network

variable "name" {
  type        = string
  description = "The name of the server you would like to provision."

  validation {
    condition     = endswith(var.name, "-server")
    error_message = "Name must end with -server"
  }
}

variable "replicas" {
  type        = number
  description = "Number of replicas of this server to create."
  default     = 1
}

variable "open_ports" {
  type        = list(number)
  description = "Ports to leave on the external (default) subnet."
  default     = []
}

variable "image" {
  type    = string
  default = "linux"
}

variable "scripts" {
  type        = list(string)
  description = "The scripts to run on this server on boot."
  default     = []
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to a public SSH key to be mounted on hosts."
  default     = "~/.ssh/id_rsa.pub"
}