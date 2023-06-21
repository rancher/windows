data "external" "kubeconfig" {
  program = ["bash", "-c", "echo \"{\\\"kubeconfig\\\": \\\"$KUBECONFIG\\\"}\""]

  lifecycle {
    postcondition {
      condition     = length(self.result.kubeconfig) > 0
      error_message = "Please point your KUBECONFIG to a cluster by running 'export KUBECONFIG=<access-key>' before running a terraform apply."
    }
  }
}

provider "kubernetes" {
  config_path = data.external.kubeconfig.result.kubeconfig
}

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

module "images" {
  source = "../internal/images"

  infrastructure_provider = var.infrastructure.azure.enabled ? "azure" : ""
}

locals {
  source_images = module.images.source_images

  rke1_cni_options = {
    flannel = {
      flannel_backend_port = "4789"
      flannel_backend_type = "vxlan"
      flannel_backend_vni  = "4096"
    }
  }

  windows_preferred = sum([
    for n in var.nodes : local.source_images[n.image].os == "windows" ? 1 : 0
  ]) > 0

  rke2_cluster_base = var.distribution == "rke2" ? templatefile("${path.module}/files/v1_cluster.yaml.tftpl", {
    name               = var.name
    fleet_workspace    = var.fleet_workspace
    cni                = var.cni
    kubernetes_version = var.rke2_version
  }) : ""

  rke1_cluster_base = var.distribution != "rke2" ? templatefile("${path.module}/files/v3_cluster.yaml.tftpl", {
    name               = var.name
    fleet_workspace    = var.fleet_workspace
    cni                = var.cni
    cni_options        = local.rke1_cni_options[var.cni]
    kubernetes_version = var.rke1_version
    windows_preferred  = local.windows_preferred
  }) : ""
}

resource "kubernetes_manifest" "cluster" {
  manifest = yamldecode([
    local.rke2_cluster_base, local.rke1_cluster_base
  ][var.distribution == "rke2" ? 0 : 1])

  dynamic "wait" {
    for_each = var.distribution == "rke2" ? ["status.clusterName"] : []
    content {
      fields = {
        "${wait.value}" = "*"
      }
    }
  }

  computed_fields = concat(["metadata.labels", "metadata.annotations"], var.distribution == "rke2" ? [] : [
    "metadata.finalizers",
    "spec",
    "status"
  ])
}

resource "time_sleep" "after_cluster_create" {
  depends_on = [kubernetes_manifest.cluster]

  create_duration = "5s"
}

# Retrieve the created cluster to get the clusterName assigned to it

data "kubernetes_resource" "cluster" {
  count = var.distribution == "rke2" ? 1 : 0

  api_version = "provisioning.cattle.io/v1"
  kind        = "Cluster"
  metadata {
    name      = var.name
    namespace = var.fleet_workspace
  }

  depends_on = [kubernetes_manifest.cluster, time_sleep.after_cluster_create]
}

locals {
  cluster_name = var.distribution == "rke2" ? data.kubernetes_resource.cluster[0].object.status.clusterName : var.name
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

# Construct the registration command

locals {
  linux_registration_command = var.distribution == "rke2" ? data.kubernetes_resource.cluster_registration_token.object.status.insecureNodeCommand : data.kubernetes_resource.cluster_registration_token.object.status.nodeCommand
  windows_registration_command = var.distribution == "rke2" ? data.kubernetes_resource.cluster_registration_token.object.status.insecureWindowsNodeCommand : join(
    "-Worker |",
    split("|", data.kubernetes_resource.cluster_registration_token.object.status.windowsNodeCommand)
  )

  registration_commands = {
    linux_controlplane        = format("%s --controlplane", local.linux_registration_command)
    linux_etcd                = format("%s --etcd", local.linux_registration_command)
    linux_worker              = format("%s --worker", local.linux_registration_command)
    linux_controlplane_etcd   = format("%s --controlplane --etcd", local.linux_registration_command)
    linux_controlplane_worker = format("%s --controlplane --worker", local.linux_registration_command)
    linux_etcd_worker         = format("%s --etcd --worker", local.linux_registration_command)
    linux_all                 = format("%s --controlplane --etcd --worker", local.linux_registration_command)
    windows_worker            = local.windows_registration_command
  }
}

# Create the nodes
module "infrastructure" {
  source = "../internal/cluster"

  cluster = {
    name         = var.name
    distribution = var.distribution
    cni          = var.cni

    linux_registration_command = local.linux_registration_command
    windows_registration_command = var.distribution == "rke2" ? local.windows_registration_command : join("\r\n", [<<-EOT
        Start-Service Docker
        $return=0; while ($return -eq 0) { try { docker ps; Write-Output "Docker has started."; $return=1 } catch { Write-Output "Waiting for docker to become available..."; sleep 1 } }
        EOT
      ,
      local.windows_registration_command
    ])

    machine_pools = var.distribution == "rke2" ? var.nodes : [
      for v in var.nodes :
      merge(v, {
        boot_scripts = concat(lookup(v, "boot_scripts", []), [
          local.source_images[v.image].os != "windows" ? <<-EOT
      curl https://releases.rancher.com/install-docker/${var.docker_version}.sh | sh
      return=1; while [ $return != 0 ]; do sleep 2; docker ps; return=$?; done
      EOT
          :
          <<-EOT
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
      Install-Module -Name DockerMsftProvider -Force
      Install-Package -Name docker -ProviderName DockerMsftProvider -Force -Confirm:$false
      EOT
        ])
      })
    ]
    servers = var.additional_servers
  }

  infrastructure      = var.infrastructure
  ssh_public_key_path = var.ssh_public_key_path
}

# Output information to access

output "name" {
  value = var.name
}

output "server_url" {
  value = local.server_url
}

output "infrastructure" {
  value = module.infrastructure.infrastructure
}