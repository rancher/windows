module "cluster" {
  source = "../internal/rancher/rke2/cluster"

  name               = var.name
  kubernetes_version = var.kubernetes_version
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
  dependencies = [for v in lookup(each.value, "dependencies", []) : "${var.name}-${v}"]

  cluster_name       = var.name
  kubernetes_version = var.kubernetes_version
  fleet_workspace    = "fleet-default"
}

locals {
  registration_commands = lookup(module.cluster, "registration_commands", {
    linux   = "echo \"Nothing to do\""
    windows = "Write-Output \"Nothing to do\""
  })
}

module "servers" {
  source = "../internal/vsphere/servers"

  servers = [
    for i in range(length(var.nodes)) :
    {
      name = "${var.name}-${var.nodes[i].image.os}-pool-${i}"
      image = {
        content_library = var.nodes[i].image.content_library
        template_path   = var.nodes[i].image.template_path
        os              = var.nodes[i].image.os
      }
      replicas           = var.nodes[i].replicas
      cpu_count          = var.nodes[i].cpu_count
      memory_in_mb       = var.nodes[i].memory_in_mb
      disk_size          = var.nodes[i].disk_size
      guest_id           = var.nodes[i].guest_id
      folder             = var.nodes[i].folder
      connection_details = var.nodes[i].connection_details
      scripts = concat(var.nodes[i].scripts != null ? var.nodes[i].scripts : [], var.nodes[i].image.os == "windows" ? [{
        name    = "join-cluster.ps1"
        content = local.registration_commands.windows
        }] : [{
        name    = "join-cluster.sh"
        content = format("%s %s", local.registration_commands.linux, join(" ", [for role in var.nodes[i].roles : "--${role}"])),
        execute = true
      }])
      windows_script_bundle = var.nodes[i].windows_script_bundle
    }
  ]

  common_connection_details = var.common_connection_details

  # vCenter specific options, shared for all vms
  data_center     = var.data_center
  resource_pool   = var.resource_pool
  compute_cluster = var.compute_cluster
  datastore       = var.datastore
  network         = var.network
}

# Output information to access

output "name" {
  value = var.name
}

output "cluster" {
  value = module.cluster
}

output "servers" {
  value = {
    machines = module.servers.vms
  }
}
