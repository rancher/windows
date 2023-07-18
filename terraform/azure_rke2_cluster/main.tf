# Create the cluster from the manifest

module "images" {
  source = "../internal/azure/images"
}

module "cluster" {
  source = "../internal/rancher/rke2/cluster"

  name               = var.name
  kubernetes_version = var.kubernetes_version
}

module "planner" {
  source = "../internal/rancher/rke2/planner"

  name                  = var.name
  registration_commands = module.cluster.registration_commands
  nodes = [
    for node in var.nodes : merge(node, {
      os = module.images.source_images[node.image].os
    })
  ]
}

locals {
  servers = merge({
    for name, node in module.planner.plan : name => {
      name    = name
      size    = one([for v in var.nodes : v if v.name == node.template])["size"]
      subnet  = node.subnet
      image   = module.images.source_images[one([for v in var.nodes : v if v.name == node.template])["image"]]
      scripts = concat(node.scripts, one([for v in var.nodes : v if v.name == node.template])["scripts"])
    }
    }, {
    for server in var.servers : "${var.name}-${server.name}" => {
      name    = "${var.name}-${server.name}"
      size    = server.size
      subnet  = "external"
      image   = module.images.source_images[server.image]
      scripts = server.scripts
    }
  })
}

module "servers" {
  source = "../internal/azure/servers"

  name = var.name

  network = {
    type       = "rke2-calico"
    airgap     = false
    open_ports = var.open_ports
  }

  servers = values(local.servers)

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
  value = module.servers
}
