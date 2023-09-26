# Create the cluster from the manifest

module "images" {
  source = "../internal/azure/images"
}

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

module "planner" {
  source = "../internal/rancher/rke2/planner"

  name = var.name
  registration_commands = lookup(module.cluster, "registration_commands", {
    linux   = "echo \"Nothing to do\""
    windows = "Write-Output \"Nothing to do\""
  })
  nodes = [
    for node in var.nodes : merge(node, {
      os = module.images.source_images[node.image].os
    })
  ]
}

locals {
  servers = merge({
    for name, node in module.planner.plan : name => {
      name        = name
      size        = lookup(one([for v in var.nodes : v if v.name == node.template]), "size", null)
      subnet      = node.subnet
      image       = module.images.source_images[one([for v in var.nodes : v if v.name == node.template])["image"]]
      scripts     = concat(node.scripts, one([for v in var.nodes : v if v.name == node.template])["scripts"])
      domain_join = lookup(one([for v in var.nodes : v if v.name == node.template]), "domain_join", null)
    }
    }, {
    for server in var.servers : "${var.name}-${server.name}" => {
      name        = "${var.name}-${server.name}"
      size        = server.size
      subnet      = "external"
      image       = module.images.source_images[server.image]
      scripts     = server.scripts
      domain_join = server.domain_join
    }
  })
}

module "servers" {
  source = "../internal/azure/servers"

  name = var.name

  network = {
    type          = "rke2-calico"
    address_space = var.address_space
    airgap        = false
    open_ports    = var.open_ports
  }

  servers = [
    for v in local.servers : merge(v, {
      domain_join = var.active_directory != null && v.domain_join
    })
  ]

  active_directory = var.active_directory

  ssh_public_key_path = var.ssh_public_key_path
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
    machines = module.servers.machines
    debug    = module.servers.debug
  }
}
