variable "cluster" {
  type        = string
  description = "The cluster you would like to deploy apps onto."
}

variable "apps" {
  type = any
  # Due to terraform typing constraint, we cannot impose the following structure
  # since it would require that every field be supplied every time. However, I'm
  # leaving this here purely to document the accepted fields
  # type = map(object({
  #   namespace    = optional(string, "default")
  #   path         = optional(string, "inline")
  #   manifest     = optional(string, null)
  #   values       = optional(any, null)
  #   values_file  = optional(string, null)
  #   dependencies = optional(list(string), [])
  # }))
  description = "Apps deployed as Bundles that will be created by Fleet in the downstream cluster."
  default     = {}
}
