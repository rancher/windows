variable "api_server_address" {
  type        = string
  description = "An IP Address or FQDN that can be used to contact the API Server at port 6443."
}

variable "create_file" {
  type        = bool
  description = "Whether to create a file containing a script that can be run on a host with kubectl access to the cluster to add this user."
  default     = true
}
