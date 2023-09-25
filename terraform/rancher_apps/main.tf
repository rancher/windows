
locals {
  fleet_workspace = var.cluster != "local" ? "fleet-default" : "fleet-local"
}

data "kubernetes_resource" "cluster" {
  api_version = "provisioning.cattle.io/v1"
  kind        = "Cluster"
  metadata {
    name      = var.cluster
    namespace = local.fleet_workspace
  }
}

locals {
  kubernetes_version = data.kubernetes_resource.cluster.object.spec.kubernetesVersion
}


module "apps" {
  source = "../internal/rancher/fleet/bundle"

  for_each = var.apps

  name         = each.key
  namespace    = lookup(each.value, "namespace", "default")
  path         = lookup(each.value, "path", "inline")
  manifest     = lookup(each.value, "manifest", null)
  values       = lookup(each.value, "values", null)
  values_file  = lookup(each.value, "values_file", null)
  dependencies = [for v in lookup(each.value, "dependencies", []) : "${var.cluster}-${v}"]

  cluster_name       = var.cluster
  kubernetes_version = local.kubernetes_version
  fleet_workspace    = local.fleet_workspace
}

output "apps" {
  value = var.apps
}
