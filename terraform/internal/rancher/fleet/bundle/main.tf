locals {
  path_is_link = startswith(var.path, "http") || startswith(var.path, "https")

  resolved_path        = startswith(var.path, "/") || local.path_is_link ? var.path : "${path.cwd}/${var.path}"
  resolved_values_path = var.values_file == null ? "" : startswith(var.values_file, "/") ? var.values_file : "${path.cwd}/${var.values_file}"
}

data "local_file" "values" {
  count = var.values_file != null ? 1 : 0

  filename = local.resolved_values_path

  lifecycle {
    precondition {
      condition     = var.values == null
      error_message = "Cannot provide both values and values_file."
    }
  }
}

locals {
  values = var.values_file != null ? yamldecode(data.local_file.values[0].content) : var.values
}

data "helm_template" "chart" {
  count = var.manifest == null && local.values != null ? 1 : 0

  name      = var.name
  namespace = var.namespace
  chart     = local.resolved_path
  values    = [yamlencode(local.values)]

  create_namespace = true
  include_crds     = true
  # Cannot validate since the KUBECONFIG we are using is the local cluster's KUBECONFIG, not the downstream cluster's KUBECONFIG
  validate         = false
  kube_version     = var.kubernetes_version
  disable_webhooks = false
}

data "http" "manifest" {
  count = var.manifest == null && local.values == null && local.path_is_link ? 1 : 0

  url = local.resolved_path
}

locals {
  # A path without an extension at the end
  bundle_name = "${var.cluster_name}-${var.name}"
  manifest = var.manifest != null ? var.manifest : (
    local.values != null ? data.helm_template.chart[0].manifest : (
      local.path_is_link ? data.http.manifest[0].response_body : file(local.resolved_path)
    )
  )

  bundle_yaml = templatefile("${path.module}/files/bundle.yaml", {
    name              = local.bundle_name
    default_namespace = var.namespace
    cluster_name      = var.cluster_name
    fleet_workspace   = var.fleet_workspace
    manifest          = local.manifest
    depends_on        = [for v in var.dependencies : { name = v }]
  })
}

resource "kubernetes_manifest" "bundle" {
  manifest = yamldecode(local.bundle_yaml)
}

output "bundle_name" {
  value = local.bundle_name
}
