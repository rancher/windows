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
  manifest = yamldecode(templatefile("${path.module}/files/v1_cluster.yaml.tftpl", {
    name               = var.name
    kubernetes_version = var.kubernetes_version
  }))

  dynamic "wait" {
    for_each = ["status.clusterName"]
    content {
      fields = {
        "${wait.value}" = "*"
      }
    }
  }

  computed_fields = ["metadata.labels", "metadata.annotations"]
}

resource "time_sleep" "after_cluster_create" {
  depends_on = [kubernetes_manifest.cluster]

  create_duration = "5s"
}

# Retrieve the created cluster to get the clusterName assigned to it

data "kubernetes_resource" "cluster" {
  api_version = "provisioning.cattle.io/v1"
  kind        = "Cluster"
  metadata {
    name      = var.name
    namespace = "fleet-default"
  }

  depends_on = [kubernetes_manifest.cluster, time_sleep.after_cluster_create]
}

locals {
  cluster_name = data.kubernetes_resource.cluster.object.status.clusterName
}

# Use the cluster name to identify the cluster registration token for this cluster

data "kubernetes_resource" "cluster_registration_token" {
  api_version = "management.cattle.io/v3"
  kind        = "ClusterRegistrationToken"
  metadata {
    name      = "default-token"
    namespace = local.cluster_name
  }

  depends_on = [kubernetes_manifest.cluster, time_sleep.after_cluster_create]
}

