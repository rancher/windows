variable "path" {
  type        = string
  description = "The path to a manifest or Helm chart to deploy."
}

variable "name" {
  type        = string
  description = "The name of this bundle. Also the release name if it is a Helm chart."
}

variable "namespace" {
  type        = string
  description = "The release namespace for the Helm chart or the default namespace for resources if not specified."
  default     = "default"
}

variable "values" {
  type        = any
  description = "The values.yaml to apply on the chart found at the provided path. If null, it will be assumed the path points to a manifest."
  default     = null
}

variable "values_file" {
  type        = string
  description = "A file with the values.yaml to apply on the chart found at the provided path. If null, it will be assumed the path points to a manifest."
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster to deploy this bundle on."
}

variable "fleet_workspace" {
  type        = string
  description = "The Fleet workspace this cluster resides within."
  default     = "fleet-default"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version to use to generate a helm template."
  default     = null
}

variable "dependencies" {
  type        = list(string)
  description = "The names of other bundles this bundle depends on."
  default     = []
}

variable "manifest" {
  type        = string
  description = "A manifest directly passed to this module as a string. If this is passed, the path will be ignored."
  default     = null
}
