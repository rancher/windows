# Get the Server URL

data "kubernetes_resource" "setting" {
  api_version = "management.cattle.io/v3"
  kind        = "Setting"
  metadata {
    name = "server-url"
  }
}

locals {
  server_url = data.kubernetes_resource.setting.object.value
}

# Create the cluster from the manifest

resource "kubernetes_manifest" "cluster" {
  manifest = yamldecode(templatefile("${path.module}/files/v3_cluster.yaml.tftpl", {
    name               = var.name
    kubernetes_version = var.kubernetes_version
    windows_cluster    = var.windows_cluster
  }))

  computed_fields = [
    "metadata.labels",
    "metadata.annotations",
    "metadata.finalizers",
    "spec",
    "status"
  ]
}

resource "time_sleep" "after_cluster_create" {
  depends_on = [kubernetes_manifest.cluster]

  create_duration = "5s"
}

# Use the cluster name to identify the cluster registration token for this cluster

data "kubernetes_resource" "cluster_registration_token" {
  api_version = "management.cattle.io/v3"
  kind        = "ClusterRegistrationToken"
  metadata {
    name      = "default-token"
    namespace = var.name
  }

  depends_on = [kubernetes_manifest.cluster, time_sleep.after_cluster_create]
}

